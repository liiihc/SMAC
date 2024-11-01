import re
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from lmfit.models import GaussianModel
import scipy.stats
from statsmodels.nonparametric.kernel_regression import KernelReg
import argparse

def smooth(y, box_pts):
    box = np.ones(box_pts)/box_pts
    y_smooth = np.convolve(y, box, mode='same')
    return y_smooth

def ipddis(ipdcsv):
    linex = []
    liney = []
    with open(ipdcsv, 'r') as f:
        for line in f:
            row = line.strip().split('\t')
            if len(row) < 2:
                continue
            try:
                liney.append(int(row[1]))
            except ValueError:
                continue
            match = re.findall(r'\((-?\d+\.?\d*),', row[0])
            if match:
                try:
                    linex.append(float(match[0]))
                except ValueError:
                    continue
    return linex, liney

def gaussian(x, am, sigma, mu):
    y = am / (np.sqrt(2 * np.pi * sigma**2)) * np.exp(-0.5 * (x - mu)**2 / sigma**2)
    return y

def modelpre(dframe):
    mf_rframe = dframe[dframe['x'] >= 1.6].reset_index(drop=True)
    print(mf_rframe)
    modelr = GaussianModel()
    params_r = modelr.guess(mf_rframe['y'], x=mf_rframe['x'])
    result_r = modelr.fit(mf_rframe['y'], params_r, x=mf_rframe['x'])
    sigma_r = result_r.best_values['sigma']
    center_r = result_r.best_values['center']
    amp_r = result_r.best_values['amplitude']

    residen = abs(
        dframe[(dframe['x'] <= center_r) & (dframe['x'] >= 0)]['y'] -
        gaussian(
            dframe[(dframe['x'] <= center_r) & (dframe['x'] >= 0)]['x'],
            amp_r,
            sigma_r,
            center_r
        ) -
        gaussian(
            dframe[(dframe['x'] <= center_r) & (dframe['x'] >= 0)]['x'],
            amp_r,
            sigma_r,
            center_r
        )
    )
    resi_cross = dframe['x'][residen.idxmin()]
    cros2x = 2
    fpr_t = sum(
        abs(
            dframe[(dframe['x'] >= resi_cross) & (dframe['x'] <= cros2x)]['y'] -
            gaussian(
                dframe[(dframe['x'] >= resi_cross) & (dframe['x'] <= cros2x)]['x'],
                amp_r,
                sigma_r,
                center_r
            )
        )
    )
    nor_t = sum(dframe[dframe['x'] >= resi_cross]['y'])
    fnr = scipy.stats.norm(center_r, sigma_r).cdf(resi_cross)
    return resi_cross, cros2x, fnr, fpr_t, nor_t, amp_r, sigma_r, center_r

def lmodelpre(dframe):
    mf_rframe = dframe[dframe['x'] <= 1].reset_index(drop=True)
    modelr = GaussianModel()
    params_r = modelr.guess(mf_rframe['y'], x=mf_rframe['x'])
    result_r = modelr.fit(mf_rframe['y'], params_r, x=mf_rframe['x'])
    sigma_r = result_r.best_values['sigma']
    center_r = result_r.best_values['center']
    amp_r = result_r.best_values['amplitude']

    residen = abs(
        dframe[(dframe['x'] >= center_r) & (dframe['x'] <= 1)]['y'] -
        gaussian(
            dframe[(dframe['x'] >= center_r) & (dframe['x'] <= 1)]['x'],
            amp_r,
            sigma_r,
            center_r
        ) -
        gaussian(
            dframe[(dframe['x'] >= center_r) & (dframe['x'] <= 1)]['x'],
            amp_r,
            sigma_r,
            center_r
        )
    )
    resi_cross = dframe['x'][residen.idxmin()]
    cros2x = -2
    fpr_t = sum(
        abs(
            dframe[(dframe['x'] <= resi_cross) & (dframe['x'] >= cros2x)]['y'] -
            gaussian(
                dframe[(dframe['x'] <= resi_cross) & (dframe['x'] >= cros2x)]['x'],
                amp_r,
                sigma_r,
                center_r
            )
        )
    )
    nor_t = sum(dframe[dframe['x'] <= resi_cross]['y'])
    fnr = 1 - scipy.stats.norm(center_r, sigma_r).cdf(resi_cross)
    return resi_cross, cros2x, fnr, fpr_t, nor_t, amp_r, sigma_r, center_r

def main():
    parser = argparse.ArgumentParser(description='Analyze IPD data and plot results')
    parser.add_argument('input_file', type=str, help='Input IPD data file')
    args = parser.parse_args()

    input_file = args.input_file

    posx, posy = ipddis(input_file)
    posy_smooth = smooth(posy, 10)

    posdata = {'x': posx, 'y': posy}
    posdata = pd.DataFrame(posdata)

    kr = KernelReg(posy, posx, 'c')
    posy_pre, posy_std = kr.fit(posx)

    resi_cross, cros2x, fnr, fpr_t, nor_t, amp_r, sigma_r, center_r = lmodelpre(posdata)
    fpt = fpr_t / nor_t

    print("Resi_cross:", resi_cross)
    print("FNR:", fnr)
    print("FPR:", fpt)

    output_pdf = f"{input_file}_plot.pdf"

    plt.figure(figsize=(10, 6))

    plt.scatter(
        posdata['x'],
        posdata['y'] - gaussian(posdata['x'], amp_r, sigma_r, center_r),
        s=0.5,
        color='blue',
        alpha=0.5,
        label='Residual'
    )

    plt.plot(
        posdata['x'],
        gaussian(posdata['x'], amp_r, sigma_r, center_r),
        linewidth=0.5,
        color='red',
        label='Best Fit'
    )

    ymax = np.max(posy)

    plt.vlines(
        [resi_cross],
        0,
        ymax * 1.1,
        linestyles=(0, (5, 10)),
        linewidth=1,
        colors='black',
        label='Cut-off'
    )
    plt.text(
        resi_cross,
        ymax * 0.1,
        f'Cut-off: {resi_cross:.4f}',
        rotation=90,
        verticalalignment='bottom',
        horizontalalignment='right',
        fontsize=9,
        color='black'
    )

    plt.ylim(0, ymax * 0.3)
    plt.xlim(-2, 4)

    tfpn = np.arange(resi_cross, 2, 0.01)
    plt.fill_between(
        x=tfpn,
        y1=gaussian(tfpn, amp_r, sigma_r, center_r),
        color='gray',
        alpha=0.2
    )

    tfnn = np.arange(-2, resi_cross, 0.05)
    plt.fill_between(
        x=posdata['x'],
        y1=posdata['y'] - gaussian(posdata['x'], amp_r, sigma_r, center_r),
        where=(posdata['x'] <= resi_cross),
        color='red',
        alpha=0.2
    )

    plt.style.use('seaborn-whitegrid')
    plt.scatter(posx, posy, s=2, label='A IPDr', color='black', alpha=0.8)

    textstr = '\n'.join((
        f'FNR: {fnr:.4f}',
        f'FPR: {fpt:.4f}'
    ))
    props = dict(boxstyle='round', facecolor='white', alpha=0.5)
    plt.text(
        0.05, 0.95, textstr,
        transform=plt.gca().transAxes,
        fontsize=10,
        verticalalignment='top',
        horizontalalignment='left',
        bbox=props
    )

    plt.legend()
    plt.xlabel('X')
    plt.ylabel('Y')
    plt.title('IPD Data Analysis')

    plt.savefig(output_pdf)
    print(f"Plot saved as {output_pdf}")

    plt.show()

if __name__ == "__main__":
    main()


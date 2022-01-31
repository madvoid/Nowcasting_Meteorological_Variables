import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat
from datetime import datetime, timedelta
import pandas as pd
from sklearn.linear_model import LinearRegression


if __name__ == "__main__":
    # Load data
    data_file = "LEMS_Avg_Latest.mat"
    mat_dict = loadmat(data_file)

    # Get dates
    dates = mat_dict["dates"].ravel()
    datefunc = (
        lambda x: datetime.fromordinal(int(x))
        + timedelta(days=x % 1)
        - timedelta(days=366)
    )
    dates = [datefunc(i).replace(microsecond=0) for i in dates]
    date_index = pd.DatetimeIndex(dates)

    # Load inputs
    files = ["LEMSI.csv", "LEMSJ.csv", "LEMSK.csv"]
    df = []
    for file in files:
        df.append(
            pd.read_csv(
                file, usecols=["windU", "windV", "MLX_IR_C", "Pressure", "thetaV"]
            ).add_suffix("_" + file[4])
        )
    inputs = pd.concat(df, axis=1)
    inputs["datetime"] = pd.to_datetime(dates)
    inputs = inputs.set_index(["datetime"])

    # Load targets
    # files = [
    #     "LEMSA.csv",
    #     "LEMSB.csv",
    #     "LEMSD.csv",
    #     "LEMSE.csv",
    #     "LEMSF.csv",
    #     "LEMSG.csv",
    #     "LEMSH.csv",
    #     "LEMSL.csv",
    # ]
    files = ["LEMSE.csv"]
    df = []
    for file in files:
        df.append(pd.read_csv(file, usecols=["thetaV"]).add_suffix("_" + file[4]))
    targets = pd.concat(df, axis=1)
    targets["datetime"] = pd.to_datetime(dates)
    targets = targets.set_index(["datetime"])

    # Limit dates
    inputs = inputs.loc["2016-12-16T00:00:00":"2017-03-15T09:00:00", :]
    targets = targets.loc["2016-12-16T00:00:00":"2017-03-15T09:00:00", :]

    # Split into test and train
    testInputs = inputs.loc["2017-01-15T00:00:00":"2017-01-20T00:00:00", :]
    testTargets = targets.loc["2017-01-15T00:00:00":"2017-01-20T00:00:00", :]

    trainBool = np.logical_or(
        inputs.index < "2017-01-15T00:00:00", inputs.index > "2017-01-20T00:00:00"
    )
    trainInputs = inputs.loc[trainBool, :].copy()
    trainTargets = targets.loc[trainBool, :].copy()

    # Train
    periods = ["5min", "10min", "15min", "30min", "1H"]
    true = {}
    pred = {}
    for period in periods:
        rTrainInputs = trainInputs.resample(period).mean()
        rTrainTargets = trainTargets.resample(period).mean()
        rTestInputs = testInputs.resample(period).mean()
        rTestTargets = testTargets.resample(period).mean()
        mod = LinearRegression()
        good_val = np.logical_not(
            np.logical_or(
                np.any(rTrainInputs.isna(), axis=1),
                np.any(rTrainTargets.isna(), axis=1),
            )
        ).values
        mod.fit(rTrainInputs.loc[good_val, :], rTrainTargets.loc[good_val, :])
        true[period] = rTestTargets
        pred[period] = mod.predict(rTestInputs)

    # Plot
    fig, axes = plt.subplots(len(periods), 1, figsize=(14, 10))
    colors = ["tab:blue", "tab:orange", "tab:green", "tab:red", "tab:purple"]
    for idx, period in enumerate(periods):
        ax = axes[idx]
        ax.plot(
            true[period].index,
            true[period].values,
            ".",
            markersize=2,
            color=colors[idx],
            label=f"True",
        )
        ax.plot(
            true[period].index, pred[period], "-", color=colors[idx], label=f"Predicted"
        )
        ax.set_xlabel("Date")
        ax.set_ylabel("Virtual\nPotential\nTemperature (K)")
        ax.set_title(f"{period} Averaging Period")
        ax.legend()
    fig.tight_layout()
    fig.savefig(f"Averaging_Period_{files[0][0:5]}.png")
    plt.show()

import pandas as pd
import os

# Folder where CSVs are stored
folder = r'D:/Ola_DATA_Analysis/Tables'

# === Define the Excel files and their respective CSVs ===
files = {
    "Operational_Efficiency_Insights.xlsx": [
        'average_VTAT_and_CTAT.csv',
        'highest_ride_completion.csv',
        'percentageOfIncompleteBookings.csv',
        'top_reasons_for_incomplete_bookings.csv',
        'routes_with_higher_cancellation_rates.csv'
    ],
    "Financial_Insights.xlsx": [
        'vehicle_revenue_summary.csv',
        'avg_booking_value_per_vehicle.csv',
        'estimated_revenue_loss_view.csv',
        'revenue_per_km_per_route.csv',
        'revenue_per_km_per_vehicle.csv',
        'Average_Booking_Value_by_Payment_Method.csv'
    ],
    "Customer_Behavior_and_Satisfaction.xlsx": [
        'highest_ride_requests.csv',
        'completion_rate.csv',
        'most_frequent_route.csv',
        'highest_revenue.csv',
        'poor_customer_rating.csv',
        'poor_driver_rating.csv'
    ]
}

# === Write each file ===
for file_name, csv_files in files.items():
    output_path = os.path.join(folder, file_name)
    with pd.ExcelWriter(output_path, engine='xlsxwriter') as writer:
        for csv_file in csv_files:
            path = os.path.join(folder, csv_file)
            if os.path.exists(path):
                df = pd.read_csv(path)
                if df.empty:
                    print(f"⚠️ Empty file skipped: {csv_file}")
                    continue

                # Clean sheet name to be valid and within Excel's limit (31 chars)
                sheet_name = os.path.splitext(csv_file)[0][:31]
                df.to_excel(writer, sheet_name=sheet_name, index=False)

                # Auto-adjust column width
                worksheet = writer.sheets[sheet_name]
                for i, col in enumerate(df.columns):
                    col_len = max(df[col].astype(str).map(len).max(), len(col)) + 2
                    worksheet.set_column(i, i, col_len)
            else:
                print(f"⚠️ File not found: {csv_file}")

    print(f"✅ Created Excel file: {output_path}")

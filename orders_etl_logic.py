import pandas as pd
from sqlalchemy import create_engine

def main():
    orders_table = 'data/H+ Sport Orders.xlsx'
    orders = pd.read_excel(orders_table, sheet_name='data')
    orders = orders[['OrderID', 'Date', 'TotalDue', 'Status', 'CustomerID', 'SalespersonID']]

    conn_url = "postgresql://etl:eTl@localhost:5432/etl"
    engine = create_engine(conn_url)

    # Works with pandas==2.2.0
    with engine.connect() as conn:
        orders.to_sql("orders", conn, if_exists='replace', index=False)
    print('ETL script executed successfully')

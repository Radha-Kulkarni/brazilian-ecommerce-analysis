# Olist Brazilian E-Commerce Analysis | 2016–2018

**Tools:** SQL · Excel · Power BI
**Dataset:** [Olist Brazilian E-Commerce Dataset (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
**Status:** Completed

---

## Project Overview

This project analyzes the Olist Brazilian e-commerce platform to uncover revenue trends, top-performing categories, state-level performance, and payment behaviour across 2016–2018.

> *"Which categories and states drive the most revenue — and how are customers paying?"*

---

## Download

The Excel and Power BI files cannot be previewed on GitHub. To view them:

1. Click the file in the repository
2. Click **Download raw file** to download it to your device
3. Open `olist_full_summary_v2.xlsx` in Microsoft Excel and `Olist_Ecommerce_Dashboard.pbix` in Power BI Desktop

---

## Repository Structure

```
brazilian-ecommerce-analysis/
├── README.md
├── Insurance_queries.sql
├── olist_full_summary_v2.xlsx
└── Olist_Ecommerce_Dashboard.pbix
```

---

## Dashboard KPIs

| Metric | Value |
|---|---|
| Total Revenue | 13.81M |
| Total Orders | 99K |
| Avg Order Value | 139.68 |
| Freight % | 16.65% |

---

## Dashboard Visuals

- Monthly Revenue Trend (2016–2018)
- Total Revenue by Category
- Total Revenue by State
- Payment Method Split

---

## Key Analysis Areas

| File | Description |
|---|---|
| `olist_full_summary_v2.xlsx` | Full cleaned dataset with pivot table summaries |
| `Olist_Ecommerce_Dashboard.pbix` | Interactive Power BI dashboard with slicers for Category and State |
| `Insurance_queries.sql` | SQL queries used for data extraction and aggregation |

---

## SQL Techniques Used

- `GROUP BY` aggregations for revenue and order summaries
- `CASE WHEN` for category and state segmentation
- Window functions for monthly trend calculations
- `JOIN` operations across multiple Olist dataset tables
- CTEs for multi-step aggregations

---

## Key Insights

1. **Health & Beauty is the top revenue category**, followed by watches and bed/bath products.
2. **SP (São Paulo) dominates state revenue** by a significant margin over all other states.
3. **Credit card is the dominant payment method** at 77.27%, with boleto second at 16.87%.
4. **Revenue grew steadily from 2017 into mid-2018**, with a visible peak around early 2018.
5. **Freight costs at 16.65%** represent a meaningful share of revenue worth monitoring for margin impact.

---

## Business Recommendations

- Prioritize inventory and marketing spend in Health & Beauty and Watches categories
- Expand logistics capacity in São Paulo given its outsized revenue contribution
- Investigate the mid-2018 revenue dip to understand if it signals seasonal patterns or churn
- Consider incentives to shift boleto users toward credit card to reduce payment friction

---

## About

**Radha** — 2nd Year Engineering Student | Aspiring Data Analyst
Skills: SQL · Python · Excel · Power BI

---

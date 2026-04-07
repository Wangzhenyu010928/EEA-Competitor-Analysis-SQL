# EEA-Competitor-Analysis-SQL
SQL scripts for processing 40k+ Google Ad transparency data in BigQuery.
📌 Project Overview
本项目基于 Google Ads Transparency Center 的公开数据集，利用 Google BigQuery (SQL) 深度挖掘 EEA（欧洲经济区）市场头部广告主的投放行为。通过构建四维策略分群模型，揭示全球顶级品牌在规模化扩张中如何平衡“受众覆盖”与“精准定向”。

🔍 SQL Logic Highlights (Technical Depth)
本项目核心 SQL 逻辑包含以下高阶技术点，解决了原始数据结构复杂的挑战：
UNNEST() Functions: 解析嵌套的地理覆盖数据（Regions Served），将多国覆盖转化为可分析的行记录。
Common Table Expressions (CTEs)：构建多层逻辑链条，确保数据清洗、指标计算与排名分析的模块化与可读性。
Strategy Segmentation: 利用 CASE WHEN 逻辑，结合素材占比（Video/Image Ratio）与定向得分（Target Score）构建自定义分群模型。

📈 Key Insights
Market Dominance: 识别出以 Amazon 和 ELEMENTARY 为代表的 Top 15 广告主占据了核心流量市场。
Precision vs. Scale: 发现头部玩家在覆盖 9 个以上国家的同时，仍能保持 1.5+ 的定向得分，打破了“覆盖越广、精度越低”的常规认知。
Media Preference: 识别出 Precision Video Leader 是目前成熟市场最主流的高效增长路径。

📊 Interactive Dashboard
👉 [点击访问 Interactive Dashboard](https://public.tableau.com/views/_17755723203010/EEA_1?:language=zh-CN&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link])

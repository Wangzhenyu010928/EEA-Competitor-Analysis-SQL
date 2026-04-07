-- 第一步：清洗并平摊 EEA 市场原始数据
WITH eea_raw_data AS (
  SELECT 
    advertiser_id,
    advertiser_legal_name,
    ad_format_type,
    r.region_code,
    r.times_shown_lower_bound AS impressions,
    -- 构建精准投放得分：地理定位 + 人口属性 (体现多维度指标分析能力) [cite: 120, 149]
    (IF(audience_selection_approach_info.geo_location != "CRITERIA_UNUSED", 1, 0) +
     IF(audience_selection_approach_info.demographic_info != "CRITERIA_UNUSED", 1, 0)) AS target_signals
  FROM `bigquery-public-data.google_ads_transparency_center.creative_stats`,
  UNNEST(region_stats) AS r -- 核心：摊平嵌套的地区数组 [cite: 9, 22]
  WHERE r.region_code IN ('DE', 'FR', 'IT', 'ES', 'PL', 'NL', 'BE', 'AT', 'SE') -- 聚焦 EEA 核心市场 [cite: 92]
),

-- 第二步：聚合广告主表现指标
advertiser_metrics AS (
  SELECT 
    advertiser_id,
    MAX(advertiser_legal_name) AS legal_name,
    COUNT(DISTINCT region_code) AS market_coverage, -- 覆盖国家数
    SUM(impressions) AS total_imp,
    -- 计算媒体组合占比 [cite: 187]
    SAFE_DIVIDE(SUM(IF(ad_format_type = 'VIDEO', impressions, 0)), SUM(impressions)) AS video_ratio,
    SAFE_DIVIDE(SUM(IF(ad_format_type = 'IMAGE', impressions, 0)), SUM(impressions)) AS image_ratio,
    SAFE_DIVIDE(SUM(IF(ad_format_type = 'TEXT', impressions, 0)), SUM(impressions)) AS text_ratio,
    AVG(target_signals) AS avg_target_score -- 平均定位精度
  FROM eea_raw_data
  GROUP BY 1
  HAVING total_imp > 500000 -- 筛选具备对标价值的活跃广告主
),

-- 第三步：计算市场基准 (Benchmark) 以供对标 [cite: 172-182]
market_analysis AS (
  SELECT 
    *,
    -- 使用窗口函数计算全市场的平均视频占比
    AVG(video_ratio) OVER() AS market_avg_video,
    -- 使用窗口函数计算全市场的平均定位精度
    AVG(avg_target_score) OVER() AS market_avg_target,
    -- 展现量全球排名
    RANK() OVER(ORDER BY total_imp DESC) AS market_rank
  FROM advertiser_metrics
)

-- 第四步：生成最终结果并打上“策略标签”
SELECT 
  *,
  CASE 
    WHEN video_ratio > market_avg_video AND avg_target_score > market_avg_target THEN 'Precision Video Leader'
    WHEN video_ratio > market_avg_video AND avg_target_score <= market_avg_target THEN 'Mass Video Aggressor'
    WHEN video_ratio <= market_avg_video AND avg_target_score > market_avg_target THEN 'Targeting Specialist'
    ELSE 'Traditional Efficient Player'
  END AS strategy_segment
FROM market_analysis
ORDER BY total_imp DESC;

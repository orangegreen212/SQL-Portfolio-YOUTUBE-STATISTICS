--1a.Top Keywords by Average Views (Maximum Reach)

SELECT
  keyword,
  ROUND(AVG(views), 0) AS avg_views,
  ROUND(AVG(Likes_video), 0) AS avg_likes,
  ROUND(AVG(Comments), 0) AS avg_comment_count,
  COUNT(video_id) AS number_of_videos
FROM
  `quiet-rigging-422416-j7.market_metric.video-stat`
GROUP BY
  keyword
HAVING
  COUNT(video_id) > 1
ORDER BY
  avg_views DESC;

--1b. Top Keywords by Average Likes (Audience Approval)
SELECT
  keyword,
  ROUND(AVG(views), 0) AS avg_views,
  ROUND(AVG(Likes_video), 0) AS avg_likes,
  ROUND(AVG(Comments), 0) AS avg_comment_count,
  COUNT(video_id) AS number_of_videos
FROM
  `quiet-rigging-422416-j7.market_metric.video-stat`
GROUP BY
  keyword
HAVING
  COUNT(video_id) > 1
ORDER BY
  avg_likes DESC;

--1c. Top Keywords by Average Comments (Highest Engagement)
SELECT
  keyword,
  ROUND(AVG(views), 0) AS avg_views,
  ROUND(AVG(Likes_video), 0) AS avg_likes,
  ROUND(AVG(Comments), 0) AS avg_comment_count,
  COUNT(video_id) AS number_of_videos
FROM
  `quiet-rigging-422416-j7.market_metric.video-stat`
GROUP BY
  keyword
HAVING
  COUNT(video_id) > 1
ORDER BY
  avg_comment_count DESC;

--2. Engagement vs. Comment Sentiment
WITH video_sentiment_summary AS (
  -- First, calculate sentiment metrics for each video
  SELECT
    video_id,
    ROUND(AVG(sentiment),2) AS avg_sentiment,
    ROUND(STDDEV(sentiment),2) AS sentiment_stddev -- Higher value means more polarized
  FROM
    `quiet-rigging-422416-j7.market_metric.comments`
  GROUP BY
    video_id
)
-- Now, join these metrics with video stats
SELECT
  stats.title,
  stats.views,
  stats.Likes_video,
  stats.Comments,
  summary.avg_sentiment,
  summary.sentiment_stddev
FROM
  `quiet-rigging-422416-j7.market_metric.video-stat` AS stats
JOIN
  video_sentiment_summary AS summary ON stats.video_id = summary.video_id
ORDER BY
  stats.views DESC;

--3. Comment Volume vs. Comment Sentiment

WITH comment_proportions AS (
  SELECT
    video_id,
    -- SAFE_DIVIDE prevents errors if a video has zero comments
    ROUND(SAFE_DIVIDE(COUNTIF(sentiment IN (0, 2)), COUNT(*)),2) AS polarized_proportion,
    ROUND(SAFE_DIVIDE(COUNTIF(sentiment = 1), COUNT(*)),2) AS neutral_proportion
  FROM
    `quiet-rigging-422416-j7.market_metric.comments`
  GROUP BY
    video_id
)
SELECT
  stats.title,
  stats.Comments,
  prop.polarized_proportion,
  prop.neutral_proportion
FROM
  `quiet-rigging-422416-j7.market_metric.video-stat` AS stats
JOIN
  comment_proportions AS prop ON stats.video_id = prop.video_id
ORDER BY
  stats.Comments DESC;

--4. Top Liked Comments and Their Sentiment

SELECT
  stats.title,
  comments.Likes_comms,
  CASE comments.sentiment
    WHEN 0 THEN 'Negative'
    WHEN 1 THEN 'Neutral'
    WHEN 2 THEN 'Positive'
  END AS sentiment_label,
  stats.views AS video_views
FROM
  `quiet-rigging-422416-j7.market_metric.comments` AS comments
JOIN
  `quiet-rigging-422416-j7.market_metric.video-stat` AS stats
  ON comments.video_id = stats.video_id
ORDER BY
  comments.Likes_comms DESC
LIMIT 20;

--5. Videos with Disabled Comments

SELECT
  CASE
    WHEN Comments = 0 THEN 'Comments Disabled'
    ELSE 'Comments Enabled'
  END AS comment_status,
  COUNT(*) AS number_of_videos,
  SAFE_DIVIDE(COUNT(*), (SELECT COUNT(*) FROM `quiet-rigging-422416-j7.market_metric.video-stat`)) * 100 AS percentage_of_total,
  AVG(views) AS average_views
FROM
  `quiet-rigging-422416-j7.market_metric.video-stat`
GROUP BY
  comment_status;

-- 6. Keywords and Their Impact on Sentiment

WITH video_sentiment_summary AS (
  SELECT
    video_id,
    ROUND(AVG(sentiment),2) AS avg_sentiment
  FROM
    `quiet-rigging-422416-j7.market_metric.comments`
  GROUP BY
    video_id
)
SELECT
  stats.keyword,
  ROUND(AVG(summary.avg_sentiment),2) AS avg_sentiment_by_keyword,
  SUM(stats.views) AS total_views_by_keyword,
  COUNT(stats.video_id) AS number_of_videos
FROM
  `quiet-rigging-422416-j7.market_metric.video-stat` AS stats
JOIN
  video_sentiment_summary AS summary ON stats.video_id = summary.video_id
GROUP BY
  stats.keyword
ORDER BY
  avg_sentiment_by_keyword DESC;

--7. Publication Date and Performance
WITH video_sentiment_summary AS (
  SELECT
     video_id, 
    AVG(Sentiment) AS avg_sentiment
  FROM
    `quiet-rigging-422416-j7.market_metric.comments`
  GROUP BY
    video_id
)
SELECT

  DATE_TRUNC(PARSE_DATE('%d.%m.%Y', stats.Published_At), MONTH) AS publication_month,

  AVG(stats.Views) AS average_views,
  ROUND(AVG(stats.Likes_video),2) AS average_likes,
  ROUND(AVG(summary.avg_sentiment),2) AS average_sentiment
FROM

  `quiet-rigging-422416-j7.market_metric.video-stat` AS stats
LEFT JOIN
  video_sentiment_summary AS summary ON stats.video_id = summary.video_id 
WHERE
  stats.Published_At IS NOT NULL AND stats.Published_At != '' 
GROUP BY
  publication_month
ORDER BY
  publication_month ASC;

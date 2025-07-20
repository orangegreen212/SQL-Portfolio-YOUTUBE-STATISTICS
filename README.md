SQL-Based Analysis of YouTube Video Performance
Link to the dataset on Kaggle
Project Overview

This project performs a deep-dive analysis of a YouTube statistics dataset using SQL. The primary goal is to uncover patterns related to video performance, audience engagement, and comment sentiment. By joining and analyzing data on video statistics, comments, and keywords, this analysis aims to answer key questions about what drives success on the platform.

The analysis leverages advanced SQL techniques, including Common Table Expressions (CTEs), aggregate functions, joins, and conditional logic with CASE statements.

Tools Used

Database: Google BigQuery (inferred from the SQL dialect and syntax like SAFE_DIVIDE).

Language: SQL

Key Questions Explored

Which keywords are associated with the highest-performing videos?

Do videos with high engagement (likes, views) tend to have more positive, negative, or neutral comments?

What is the relationship between comment volume and comment sentiment?

Which videos have the most liked comments, and what is the sentiment of those top comments?

What proportion of videos have disabled comments?

Are there keywords that consistently result in higher comment sentiment?

How does the publication date relate to performance over time?

Analysis and Findings

Here is a breakdown of the approach and key insights for each question.

1. Which keywords are associated with the highest-performing videos?

Methodology:
I aggregated video statistics by keyword, calculating the average views, likes, and comments for each. The results were then ordered to identify the top-performing keywords for each metric.

Generated sql
-- Simplified example of the logic used
SELECT
  keyword,
  ROUND(AVG(views), 0) AS avg_views,
  ROUND(AVG(Likes_video), 0) AS avg_likes,
  ROUND(AVG(Comments), 0) AS avg_comment_count
FROM
  `market_metric.video-stat`
GROUP BY
  keyword
ORDER BY
  avg_views DESC;


Findings:

By Views: Keywords like "google", "animals", and "mrbeast" are associated with the highest average view counts.

By Likes: "nintendo", "mrbeast", and "xbox" rank among the highest for average likes, indicating strong engagement within the gaming community.

By Comments: "mrbeast" stands out significantly, generating the highest average number of comments, reinforcing its reputation for driving massive audience interaction.

2. Do high-engagement videos have more polarized comments?

Methodology:
To analyze the relationship between engagement and sentiment, I first created a CTE to calculate the average sentiment and the standard deviation of sentiment for each video using AVG(sentiment) and STDDEV(sentiment). A higher standard deviation indicates more polarized comments. This summary was then joined back to the main video statistics table.

Generated sql
-- Simplified logic
WITH video_sentiment_summary AS (
  SELECT
    video_id,
    ROUND(AVG(sentiment), 2) AS avg_sentiment,
    ROUND(STDDEV(sentiment), 2) AS sentiment_stddev
  FROM
    `market_metric.comments`
  GROUP BY
    video_id
)
SELECT
  stats.title,
  stats.views,
  summary.avg_sentiment,
  summary.sentiment_stddev
FROM
  `market_metric.video-stat` AS stats
JOIN
  video_sentiment_summary AS summary ON stats.video_id = summary.video_id
ORDER BY
  stats.views DESC;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
SQL
IGNORE_WHEN_COPYING_END

Findings:
Highly popular videos often exhibit an average sentiment score in the neutral-to-positive range (1.1 to 1.7). The standard deviation metric shows that high-view videos attract a wide range of opinions, leading to more polarized comment sections.

3. What is the relationship between comment volume and sentiment?

Methodology:
I calculated the proportion of "polarized" comments (sentiment = 0 or 2) versus neutral comments (sentiment = 1) for each video. This was achieved using COUNTIF and SAFE_DIVIDE within a CTE to prevent division-by-zero errors.

Findings:
There is a clear trend indicating that videos with a very high volume of comments also have a higher proportion of polarized comments. This suggests that as engagement scales, discussion becomes less neutral and more emotionally charged.

4. What is the sentiment of the most-liked comments?

Methodology:
A CASE statement was used to translate numeric sentiment scores (0, 1, 2) into readable labels ('Negative', 'Neutral', 'Positive'). I then joined the comments and video statistics tables and ordered the results by Likes_comms in descending order.

Findings:
The most-liked comments are not always positive. For the video "$456,000 Squid Game In Real Life!", the top-liked comments include both 'Positive' and 'Negative' sentiments. This is a crucial insight: highly engaging and viral content often thrives on discussion and controversy, where even critical comments can become extremely popular.

5. What proportion of videos have disabled comments?

Methodology:
Using a CASE statement, I classified videos into two categories: 'Comments Enabled' and 'Comments Disabled'. I then grouped by this status and calculated the number of videos, the percentage of the total using SAFE_DIVIDE, and the average views for each category.

Findings:
An overwhelming majority of videos (99.95%) have comments enabled. The tiny fraction of videos with disabled comments perform significantly worse, showing drastically lower average views (24k vs. 11.7M for videos with comments enabled). This suggests that disabling comments correlates with, or leads to, poor video performance.

6. Do certain keywords attract more positive sentiment?

Methodology:
By joining the video statistics and comment sentiment summary tables, I grouped by keyword and calculated the average sentiment for all videos associated with that keyword.

Findings:
Yes, certain keywords are strongly associated with higher positive sentiment. "Lofi", "asmr", and "music" lead the list with the highest average sentiment scores (around 1.7-1.8). This indicates that content in these niches tends to foster a more consistently positive and less controversial community response.

7. How does publication date relate to performance?

Methodology:
I used the DATE_TRUNC function to group video statistics by publication month and year. This allowed for a time-series analysis of average views, likes, and comment sentiment.

Findings:
Performance is characterized by significant peaks in certain months, likely driven by a few viral hits, rather than a steady temporal trend. For example, July 2009 shows a massive spike in average views, which is not sustained in the following months. This highlights that video performance is event-driven.

Conclusion

This SQL-based analysis provided several actionable insights into YouTube video performance. Key takeaways include the strong predictive power of keywords, the nuanced relationship between high engagement and polarized sentiment, and the clear performance disadvantage of disabling comments. The findings demonstrate that success on YouTube is a complex interplay of content type, community interaction, and topic selection.

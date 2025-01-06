
# time: 2024-12-19 03:25:03 UTC
# mode: r
+source('viz_bert_labels.R')

# time: 2024-12-19 03:25:11 UTC
# mode: r
+system("ls")

# time: 2024-12-19 03:25:28 UTC
# mode: r
+ls()

# time: 2024-12-19 03:25:36 UTC
# mode: r
+names(articles_bert_labels)

# time: 2024-12-19 03:25:41 UTC
# mode: r
+p1

# time: 2024-12-19 03:25:44 UTC
# mode: r
+p2

# time: 2024-12-19 03:25:47 UTC
# mode: r
+p3

# time: 2024-12-19 03:25:49 UTC
# mode: r
+p4

# time: 2024-12-19 03:27:12 UTC
# mode: r
+source('viz_bert_labels.R')

# time: 2024-12-19 03:28:44 UTC
# mode: r
+p5

# time: 2024-12-19 03:28:50 UTC
# mode: r
+ls()

# time: 2024-12-19 03:28:57 UTC
# mode: r
+names(articles_bert_labels_prob)

# time: 2024-12-19 03:29:19 UTC
# mode: r
+articles_bert_labels_prob$neg_score

# time: 2024-12-19 03:29:29 UTC
# mode: r
+articles_bert_labels_prob$pos_score

# time: 2024-12-19 03:30:27 UTC
# mode: r
+source('viz_bert_labels.R')

# time: 2024-12-19 03:31:20 UTC
# mode: r
+p5

# time: 2024-12-19 03:31:23 UTC
# mode: r
+ls()

# time: 2024-12-19 03:31:38 UTC
# mode: r
+source('viz_bert_labels.R')

# time: 2024-12-19 03:31:41 UTC
# mode: r
+ls()

# time: 2024-12-19 03:31:42 UTC
# mode: r
+p5

# time: 2024-12-19 03:35:18 UTC
# mode: r
+article_outliers %>% arrange(desc())

# time: 2024-12-19 03:35:24 UTC
# mode: r
+names(article_outliers)

# time: 2024-12-19 03:35:28 UTC
# mode: r
+article_outliers %>% arrange(desc(score))

# time: 2024-12-19 03:36:03 UTC
# mode: r
+test <- article_outliers %>% arrange(desc(score))

# time: 2024-12-19 03:36:14 UTC
# mode: r
+test %>% head()

# time: 2024-12-19 03:36:30 UTC
# mode: r
+test %>% head() %>% select(title, sentiment, score)

# time: 2024-12-19 03:37:34 UTC
# mode: r
+test <- article_outliers %>% arrange(score)

# time: 2024-12-19 03:37:38 UTC
# mode: r
+test %>% head()

# time: 2024-12-19 03:37:50 UTC
# mode: r
+test %>% select(title, sentiment, score)


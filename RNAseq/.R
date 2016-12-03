library("DESeq2")

countTable = read.table(".txt",header=TRUE, row.names=1)
condition = factor(c())
libType = c()
condition <- relevel(condition, "")
experiment_design=data.frame(
row.names = colnames(countTable),
condition,
libType)
cds <- DESeqDataSetFromMatrix(countData = countTable, colData=experiment_design, design=~condition)
cds_DESeqED <- DESeq(cds)
res <- results(cds_DESeqED,alpha = , pAdjustMethod = "")
write.table(res,file = ".differentialExpression.txt",row.names = TRUE,col.names = NA,append = FALSE, quote = FALSE, sep = "\t",eol = "\n", na = "NA", dec = ".")
normalizedReadCounts = counts(cds_DESeqED,normalized=TRUE)
write.table(normalizedReadCounts,file = ".normalizedCounts.xls",row.names = TRUE,col.names = NA,append = FALSE, quote = FALSE, sep = "\t",eol = "\n", na = "NA", dec = ".")

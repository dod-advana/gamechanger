Directory structure of `models` directory to be volume mount to [ml-api docker service][0]:



```
tree -L 2 /mnt/extra/models/                                                                                                         la-dev 
/mnt/extra/models/
├── bigrams.phr
├── jbook_qexp_20201217
│   ├── ann-index_1608230794.1036441.ann
│   └── ann-index-vocab_1608230794.1036441.pkl
├── ltr
├── qexp_20201217
│   ├── ann-index_1608230794.1036441.ann
│   └── ann-index-vocab_1608230794.1036441.pkl
├── sent_index_20210422
│   ├── config
│   ├── data.csv
│   ├── doc_ids.txt
│   ├── embeddings
│   ├── embeddings.npy
│   └── metadata.json
├── tfidf_dictionary.dic
├── tfidf.model
└── transformers
    ├── bert-base-cased-squad2
    ├── crawl-300d-2M.vec
    ├── distilbart-mnli-12-3
    ├── distilbert-base-uncased-distilled-squad
    ├── distilroberta-base
    ├── msmarco-distilbert-base-v2
    ├── wiki-news-300d-1M.bin -> wiki-news-300d-1M-subword.vec
    ├── wiki-news-300d-1M-subword.bin
    ├── wiki-news-300d-1M-subword.vec
    └── wiki-news-300d-1M.vec

10 directories, 18 files
```

[0]: ./docker-compose/services.yaml

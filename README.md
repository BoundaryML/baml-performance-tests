# Results of performance test

Summary: There is no significant difference in performance between versions 0.68.0, 0.60.0, and 0.56.0 of baml-py. Async vs sync has no significant difference in performance. The performance of the hello.py and hello_async.py scripts is consistent across all versions of baml-py. We ran each request 4 times.


Sorted by version number of baml-py

Setup:

```bash
uv add 'baml-py==$VERSION'
uv run baml-cli generate
```

## hello.py

Test command `BAML_LOG=off uv run python -m hello`

### 0.68.0

```text
Time taken: 23.075298070907593 seconds
Time taken: 21.76284098625183 seconds
Time taken: 27.610254049301147 seconds
Time taken: 30.99905514717102 seconds
```

### 0.60.0

```text
Time taken: 21.77516794204712 seconds
Time taken: 30.17619299888611 seconds
Time taken: 27.422985076904297 seconds
Time taken: 28.205918073654175 seconds
```

### 0.56.0

```text
Time taken: 35.25490617752075 seconds
Time taken: 28.291924953460693 seconds
Time taken: 25.345711946487427 seconds
Time taken: 39.09483003616333 seconds
```

## hello_async.py

Test command `BAML_LOG=off uv run python -m hello_async`

### 0.68.0

```text
Time taken: 26.068761110305786 seconds
Time taken: 30.400962114334106 seconds
Time taken: 32.9907660484314 seconds
Time taken: 37.55303692817688 seconds
```

### 0.60.0

```text
Time taken: 17.905033111572266 seconds
Time taken: 20.80878472328186 seconds
Time taken: 24.945499897003174 seconds
Time taken: 26.747692108154297 seconds
```

### 0.56.0

```text
Time taken: 26.69902491569519 seconds
Time taken: 29.6512610912323 seconds
Time taken: 30.27460789680481 seconds
Time taken: 30.577964782714844 seconds
```

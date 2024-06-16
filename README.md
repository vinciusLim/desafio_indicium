
# Documentação do Desafio de Código Técnico da Indicium

## Iniciando o Projeto

Para iniciar um projeto Meltano, utilize o comando: `meltano init MEU_PROJETO`


## Transferência de CSV Externo para CSV Local

O primeiro passo é pegar arquivos CSV de detalhes de compras locais e consolidá-los em um único arquivo CSV.

### Comando

```bash
meltano run tap-csv target-csv
```

### Configurações

#### `tap-csv`

```yaml
- name: tap-csv
  variant: meltanolabs
  pip_url: git+https://github.com/MeltanoLabs/tap-csv.git
  config:
    files:
    - entity: order_details
      path: dados/dados.csv
      keys:
      - order_id
```

#### `target-csv`

```yaml
- name: target-csv
  variant: meltanolabs
  pip_url: git+https://github.com/MeltanoLabs/target-csv.git
  config:
    file_naming_scheme: 'data/csv/{datestamp}/dados.csv'
```

## Transferência de Banco de Dados para CSV Local

O segundo passo é extrair dados de um banco de dados local e salvá-los em arquivos CSV em uma pasta de destino.

### Comando

```bash
meltano run tap-postgres target-csv
```

### Configurações

#### `tap-postgres`

```yaml
- name: tap-postgres
  variant: meltanolabs
  pip_url: git+https://github.com/MeltanoLabs/tap-postgres.git
  config:
    sqlalchemy_url: postgresql://postgres:1234@localhost:5432/postgres
    filter_schemas: [public]
```

#### `target-csv`

```yaml
- name: target-csv
  variant: meltanolabs
  pip_url: git+https://github.com/MeltanoLabs/target-csv.git
  config:
    validate_records: false
    add_record_metadata: false
    file_naming_scheme: 'data/postgres/{stream_name}/{datestamp}/dados.csv'
    default_target_schema: public
    default_target_table: dados_table
```

## Transferência de CSV Local para Banco de Dados Destino

O último passo é importar arquivos CSV locais para um banco de dados de destino.

### Configurações

#### `tap-csv`

```yaml
- name: tap-csv
  variant: meltanolabs
  pip_url: git+https://github.com/MeltanoLabs/tap-csv.git
  config:
    files: 
      - entity: order_details
        path: data/csv/2024-06-15/dados.csv
        keys: [order_id, product_id]
      - entity: categories
        path: data/postgres/public-categories/2024-06-15/dados.csv
        keys: [category_id]
      - entity: customers
        path: data/postgres/public-customers/2024-06-15/dados.csv
        keys: [customer_id]
      - entity: employee_territories
        path: data/postgres/public-employee_territories/2024-06-15/dados.csv
        keys: [employee_id, territory_id]
      - entity: employees
        path: data/postgres/public-employees/2024-06-15/dados.csv
        keys: [employee_id]
      - entity: orders
        path: data/postgres/public-orders/2024-06-15/dados.csv
        keys: [order_id]
      - entity: products
        path: data/postgres/public-products/2024-06-15/dados.csv
        keys: [product_id]
      - entity: region
        path: data/postgres/public-region/2024-06-15/dados.csv
        keys: [region_id]
      - entity: shippers
        path: data/postgres/public-shippers/2024-06-15/dados.csv
        keys: [shipper_id]
      - entity: suppliers
        path: data/postgres/public-suppliers/2024-06-15/dados.csv
        keys: [supplier_id]
      - entity: territories
        path: data/postgres/public-territories/2024-06-15/dados.csv
        keys: [territory_id]
      - entity: us_states
        path: data/postgres/public-us_states/2024-06-15/dados.csv
        keys: [state_id]
```

#### `target-postgres`

```yaml
- name: target-postgres
  variant: meltanolabs
  pip_url: git+https://github.com/MeltanoLabs/target-postgres.git
  config:
    sqlalchemy_url: postgresql://postgres:1234@localhost:5432/banco_destino
    default_target_schema: public
    default_target_table: dados_table
    add_record_metadata: false
    activate_version: false
```

## Consulta SQL

Com a consulta abaixo, é possível visualizar pedidos com valor bruto maior que 2000, salvo na pasta data:

```sql
SELECT * 
FROM (
    SELECT 
        o.order_id, 
        od.product_id, 
        (CAST(od.unit_price AS NUMERIC) * CAST(od.quantity AS NUMERIC)) AS preco_total_bruto
    FROM 
        orders AS o
    LEFT JOIN 
        order_details AS od
    ON 
        o.order_id = od.order_id
) AS subquery
WHERE
    preco_total_bruto > 2000;
```

aws dynamodb list-tables

aws dynamodb create-table --cli-input-json file://create-table-items.json 

aws dynamodb wait table-exists --table-name items

aws dynamodb put-item \
    --table-name items  \
    --item \
        '{"ID": {"N": "1" }, "Title": {"S": "Водка Finlandia 1л"}, "Category": {"S": "VODKA"}, "Barcode": {"S": "88474773727227"}, "StoreID": {"S": "AUCHAN"}}'

aws dynamodb put-item \
    --table-name items \
    --item \
        '{"ID": {"N": "2" }, "Title": {"S": "Коньяк Арарат 0.5л"}, "Category": {"S": "BRANDY"}, "Barcode": {"S": "88454573727227"}, "StoreID": {"S": "NOVUS"}}'

aws dynamodb query \
    --table-name items \
    --key-condition-expression "ID = :key" \
    --expression-attribute-values  '{":key":{"N":"2"}}'
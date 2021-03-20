## How to search in Kibana

### Search Types
1. Free Text - `the quick brown fox jumps over the lazy dog`

2. Field Level - `<field name>` `<operator>` `<field value>` 
    
    eg. 
    - `fox : quick`
    - `fox : quick and dog : lazy`

3. Filters
    - Select `+ Add Filter`
    - Select a `Field`
    - Select an `Operator`
    - Enter `Values`
    - `Save`

### `Free Text` search tips
- Wrap text in `""` if you like to search for a keyword with more than one word. Without the quotes, the query matches documents regardless of the order in which they appear. For example, documents with `quick brown fox` match, and so does `quick fox brown`.
- You can select any data from auto populated data for an easy search. For example, if you enter `hkpf.fields.UserId : ` and then enter a possible alphanumeric for `hkpf.fields.UserId` field, it will show all the values (from top 500 documents) for `hkpf.fields.UserId` field which has alphanumeric character you entered. 
- Terms without fields are matched against the default field in your index settings. If a default field is not set, terms are matched against all fields. For example, a query for `response : 200` searches for the value 200 in the response field, but a query for just 200 searches for 200 across all fields in your index.

### `Field Level` search tips
- Unlike `Free Text` search, `Field Level` search is case sensitive. Field name and value for the field name should be exactly as it appears in the logs. For example, `fox : quick` and `fox : Quick` are not the same.
- At the moment of writing, operators that are supported by `Field Level` search are `AND` and `OR`. `NOT` operator needs to be used with `AND` and `OR` (eg. `hkpf.fields.UserId : "10008" and not hkpf.fields.X-Api-Key : 2F8D44EA-ED10-44AD-B516-EE8D8556CDB1`). If could also exclude any logs by creating a `Filter` for the field with `NOT` operator and add it to your `Field Level` search.
- Add `*` to fields to get log documents with any value for that field. This will remove log documents which doesn't have a value. eg. `fox : *`

### `Filters` search tips
- `Filters` can be diabled.
- Add labels to the filters to make it easy to read.
- Icons (magnifier with + sign, magnifier with - sign, table sign and table with * sign) infront of the fields in a log document can be used to filter logs. This filter will pop up under the search field on top.
    - Magnifier with + sign - Filter logs which includes the value for the field. For example, if the field is `fox` and value is `quick`, then clicking on the magnifier with + sign will filter any logs which has `quick` for `fox` field.
    - Magnifier with - sign - Filter logs which includes the value for the field
    - Table sign - Add the value for the field as a column to the document table 
    - Table with * sign - Value is present on any datt you filter against
- Fields under `Available fields` in left hand side menu column can be used to filter in or out any values present in top 500 log documents. Upon clicking on the field, it will display any values (if the field has any) in the top 500 documents. You can use the magnifier with + sign or magnifier with - sign next to the value to filter in or out those values.
- Filters are additive

### Advanced Kibana search types
1. Wildcards/Fuzziness
    - `?` to replace a single character
    - `*` to replace multiple characters. 
    
        Example `the qui?k brown fox*`

2. Proximity 
    - Query words/pharases that are further apart or in a different order
    
        Example `"lazy fox"~5` (We are trying to identify a distance between two terms that we want to extract. In the example it means we don't know if its `lazy` then `fox` or `fox` then `lazy`, but we want them to be at least five tokens or words away from each other.)

3. Booting 
    - Manually specific relevance ranking of returned documents

        Example `"quick brown"^2 (fox OR dog)^4`

4. Ranges
    - Ranges can be specified for date, numeric or string fields
    - You can use `[]` and `{}` interchangeably. In its simplest form difference between `[]` and `{}` is less/greater than or equal to less than or greater than(eg. `[400 TO 500]` will include `400` and `500`. But `{400 TO 500}` will not include `400` and `500`).

        Example `response:[400 TO 500]`

5. Regular Expressions 
    - Uses regexp term queries(pattern matching)
    - Elastic has its domain-specific regexp library([Elastic - Regular expression syntax](https://www.elastic.co/guide/en/elasticsearch/reference/current/regexp-syntax.html)). So you might not get the same out put you expected because of this.
    - Wrap with forward slashes(`/foo/`)

        Example `/qui[a-z]k br~n fox/`

### Links
- [Elastic - Kibana Query Language](https://www.elastic.co/guide/en/kibana/7.9/kuery-query.html)
- [YouTube - Become a Kibana Search Expert - Part 1](https://www.youtube.com/watch?v=_nq5m9_-iS0)
- [YouTube - Become a Kibana Search Expert - Part 2](https://www.youtube.com/watch?v=pl__VEjv_4Q)
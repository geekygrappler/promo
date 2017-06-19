# API docs

Rough docs for API.

Follows [JSON:API](http://jsonapi.org/)

## Authorisation

Supply your API Key in the the `Authorization Header`

```
Authorization: '74a800b8b1b8bbe4f901d5fd91973bf5'
```

All endpoints require a key.

## Endpoints

Base `/api/v1`

### Generate

Generate a promocode for one of your promotions.

```
https://promio-test.herokuapp.com/api/v1/generate
METHOD: POST
```
Example request body
```json
{
  "data": {
    "type": "promocodes",
    "attributes": {
      "code": "WeLoveJohn10",
      "customer_email": "john@prom.io"
    },
    "relationships": {
      "promotion": {
        "type": "promotions",
        "id": 13
      }
    }
  }
}
```

####Params

**promotion id**, required: *true*, number: The ID of a promotion to generate the code for **must** be supplied under the 
included key.

**code**, required: *false*, string: A code to assign to the promocode. If not supplied a random one will be generated.

**customer_email**, required: *false*, string: An identifier for customer, some promotions require customer_email.


### Price

Price a promocode for a given cart.

```
https://promio-test.herokuapp.com/api/v1/price
METHOD: POST
```
Example request body
```json
{
  "data": {
    "type": "promocodes",
    "attributes": {
      "code": "WeLoveJohn10",
      "customer_email": "john@prom.io"
    },
    "relationships": {
      "cart": {
        "type": "carts",
        "attributes": {
          "item_total": "100.99",
          "delivery_total": "9.99"
        }
      }
    }
  }
}
```
If the promocode was linked to a promotion that gave 10% off items in the cart the following response object
```json
{
  "data": {
    "type": "prices",
    "attributes": {
      "original_item_total": "100.99",
      "discounted_item_total": "90.89",
      "item_discount": "10.10",
      "original_delivery_total": "9.99",
      "discounted_delivery_total": "9.99",
      "delivery_discount": "0",
      "original_total": "111.98",
      "discounted_total": "101.88",
      "total_discount": "10.10"
    }
  }
}
```


##Example

Test API key: 'bd532523d0abbeb39ce3cc581ff5c311'

Example Promocode: 'WeLoveJohn10'

email: 'john@prom.io'

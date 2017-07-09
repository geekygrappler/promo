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
https://promio-test.herokuapp.com/api/v1/promocodes/generate
METHOD: POST
```
**Example request body**
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

**promocode code**, required: *false*, string: A code to assign to the promocode. If not supplied a random one will be generated.

**customer_email**, required: *false*, string: An identifier for customer, some promotions require customer_email.

**Example Successful Response**

```json
{
  "data": {
    "id": "158", 
    "type": "promocodes", 
    "attributes": {
      "code": "WeLovevJohn10", 
      "customer-email": "john@prom.io" 
    }
  }
}
```

### Price

Price a promocode for a given cart.

```
https://promio-test.herokuapp.com/api/v1/promocodes/price
METHOD: POST
```
**Example request body**
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
        "id": "yourUniqueCartId",
        "attributes": {
          "item_total": "100.99",
          "delivery_total": "9.99"
        }
      }
    }
  }
}
```

####Params

**promocode**, required: *true*, string: The promocode to price the cart with.

**customer_email**, required: *false*, string: Some promocodes require a customer email.

**cart id**, required: *true*, string: A unique identifier for your cart that cannot change during checkout process.

**cart attributes**, required: *true*, object: A representation of your cart, at minimum either item or delivery total.
It can include more detail for other promotions. e.g. specific cart items.

**Example Successful Response**
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


### Redeem

Inform the service that a cart has been purchased and mark all associated promocodes as redeemed

```
https://promio-test.herokuapp.com/api/v1/carts/redeem
METHOD: POST
```

**Example request body**
```json
{
  "data": {
    "type": "carts",
    "id": "yourUniqueCartId"
  }
}
```

####Params

**cart id**, required: *true*, string: A unique idetifier for your cart that has not changed since the cart was priced.

This endpoint will just return a 200 or error.

##Example

Test API key: 'bd532523d0abbeb39ce3cc581ff5c311'

Example Promocode: 'WeLoveJohn10'

email: 'john@prom.io'

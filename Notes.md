# Promo Service

- Use cases
- API
- Marketing Manager web client

## Use cases

1. Promocodes
2. Analytics
3. Loyalty scheme

### Promocodes

Bread and butter. MVP. Order of development.
- Developers can generate, apply and mark promocodes redeemed through an API.
- Marketing managers can create promocodes (through some web client).

What kind of promotions?
- Newsletter signup, unique code for each new customer to signup.
- General ad campaigns, one code used by many many customers.
- Customer services offering compensation vouchers or money off easily & quickly.

The goal is to create a flexible set of constraints so users can create
any kind of promotion they want.
For example a General ad campaign would have the following constraints:
MultiCustomer = Can be used by multiple customers
SingleCustomerRedemption = Can only be redeemed by a specific customer one time

However they could also create an internal staff promocode:
MultipleCustomer = Can be used by multiple customers.
The lack of any other constraints means that a customer can use it as many times
as they want. However, a sensible marketing manager might add this constraint:
SpecificCustomerGroup = Can only be redeemed by customers who's email domain is @moo.com for example.

Flexible constraint with sensible defaults on the webclient, e.g. if your creating
a newsletter sign up the defaults would be:
SpecificCustomer = Each promocode is linked to a specific user
SingleRedemption = Each promocode can only be used once.

*N.B. From doing this I don't think MultiCustomer is constraint. It's the default.
The default is MultiCustomer and MultiRedemption. The Constraints are SpecificCustomer
and SingleRedemption. This is for the code, but in the webclient, these will be presented
as constraints to the user*


### Analytics

You know when developers say they'll build a promo service internally in 1 or 2 sprints
and ABSOLUTELY they'll implement tracking so marketing managers can say,
'We ran FREE DELIVERY SUMMER and that code was used 11,238 times and generated
revenue of £231,231 at a cost of £56,038.' Please don't fire me, I'm useful.

But in reality it takes 5 sprints without tracking and tracking needs a ticket
per campaign, which only gets run in a sprint half way through the campaign, so
all the numbers are bullshit.

Be nice to offer that to Users. Makes Devs lives easier *and* marketing managers.

### Loyalty scheme

You know the awesome Uber referal scheme. Awesome. Not a promocode, more of a
loyalty scheme. Need to be able to have records of customers for a Company
and keep accounts of how much credit they've accrued in order to apply it at the checkout.

There is a hack of creating a unique promotion (promocode) for a customer
that can be used by any other customer, and each time it is, generate another
promotion (promocode) that you send to the original user. It's not as slick
as a loyalty scheme.

This is a nice to have in the future but not core.

## API

- Endpoints
- Constraints
- Modifiers
- Models

Way for developers to generate promocodes e.g. for News letter singup.

Way for developers to get a value of a basket with a promocode in it.

Way for developers to redeem promocode (mark it as used).

*N.B. Using json:api so requests and responses need to follow that.*

*N.B Important nomenclature*
- User: Person/Dev/Company using Promo Service
- Customer: Person/Dev/Companies customers

### Endpoints

Some things might not be clear until after reading models. Some things definitely
even less clear after reading models. :)

```
/*
 * Generate a Promocode for a customer.
 * Used for a Promotion that is for a specific users. e.g. Newsletter signup.
 * promotion_id could be 'name' of a promotion.
 *
 * POST /generate
 * @param customer_email:string
 * @param promotion_id:number
 * @return PromoCode: {code:string, id:number, customer_email:string}
 */
```

```
  /*
   * Calculate basket price with promocode applied.
   * Basket is pseudo basket. The type Item could be something like:
   * { description:string, quantity:number, unit_price:number, total_price:number}
   * Where the user can supply any or none of the keys. If they don't it Limits
   * the constraints we can apply. E.g. Promotion for a specific item in the basket.
   * Equally they don't have to provide customer_email at this point but stops us
   * pricing a promotions with specific customer constraint.
   *
   * GET /price
   * @param customer_email:string
   * @param promocode:string
   * @param Basket: { items: Item[], delivery_cost:number, item_total: number }
   * @return ???: {original_total: number, discounted_total: number, discount: number}
   */
```

```
  /*
   * Mark a promocode as redeemed. This should be done after a successful transaction.
   * Here Basket isn't *required*. We assume the developer has called `/price`
   * endpoint earlier in the checkout price in order to calculate what to
   * charge the customer. It is however nice to have the basket. If the basket
   * is not passed, we'll need to go find the last time that `/price` was called
   * with that promocode and user combination. So we'll have to keep a record of that. Maybe we should just require it.
   * But the point of redeem is to increment it's redemption_count by creating a
   * Redemption record, which we can use for reporting.
   *
   * POST /redeem
   * @param customer_email:string
   * @param promocode:string
   * /* @param Basket */
   * @return General success??
   */
```

3 endpoints. Simples.

### Constraints

What is a constraint?
A pre-condition that must be met in order to apply a promotion.

Constraints live on the promotion.

**Single Promocode:** The Promotion can only have 1 promocode associated to it.

The default is for a promocode to be able to have many promocodes associated to it.

**Specific Customer (Promocode):** Must match the email of the customer who owns the promocode. 
(usually paired with Multiple promocode promotions, but don't want to constrain it to that, be flexible)

The default is for any customer to be able to use a promocode.

**Unique Customer Generation (Promotion):** Can only be generated once per customer email.

**Single Redemption (Promocode):** Promocode can only be redeemed once.

The default is for a promocode to be redeemable unlimited times.

**Unique Customer Redemption (Promotion via redemptions):** A customer can only redeem the code once. e.g. can be redeemed
multiple times, but only once by each user. SUMMER 10

**Promotion Period (Promotion):** Promotions have start and end date during which they can be redeemed.

**Minimum Basket Total (Promotion):** Minimum total for a basket

**Basket Contains (Promotion needs something more):** some sketchy regex on item description.

**Customer Group (Promotion):** email domain regex

*N.B. More to be added maybe? We want to keep this list as short as possible while
covering as many use cases as possible*

### Modifiers

What is a modifier?
Changes the total_price of a basket.

**Percentage Discount:** e.g. 10% off

**Fixed Discount:** e.g. £10 off

Could have Delivery, Item, and total, but lets stick to total price with flexibility to extend it.

**Free Delivery:** e.g. delivery_cost: 0

This is just a special case of Percentage Delivery Discount (100%) and in the code we should
just have the 6 above and on the front end a 'free delivery' constraint which is actually just 100% delivery discount.

TODO there might need to be some kind of application order logic, like A preceeds B but don't need that just yet.

N.B. Total precludes the possibility of having an item or delivery price modifier, but you can have item and
delivery modifiers on the same Promotion.

### Models

This is what Marketing managers see and can create on the web client.
```
Promotion {
  /*
   * Human friendly name e.g. "Summer Delivery Campaign" or "Newsletter Promo"
   */
  name: string,

  /*
   * Point from which promotion is valid
   * Can't be null. If not provided, duplicate created_at datetime
   * If only date is supplied, set to 12pm on that day? (ask a marketing manager)
   */
  start_date: datetime,

  /*
   * Point from which promotion is no longer valid
   * Can be null. Indicates infinite promotion.
   * We should probably have a end promotion method that sets the end date to Time.now
   */

  end_date: datetime,
  /*
   * belongs_to User
   */
  user_id: number

  /*
   * Don't know if we should implement this, have the other side on Promocode.
   * Don't need it now, might do for analytics.
   * has_many Promotion
   */
  promocode_ids: number[],

  /*
   * Constraints. Two ways I can see to do them so far.
   */

  /*
   * has_many Constraint
   * ActiveRecord relationship, but I don't know if a Constraint should be a
   * record. I think a constraint is a class.
   */
  constraint_ids: [],

  /*
   * We have different types of Constraint (inheritance?)
   * e.g. [SPECIFIC_CUSTOMER, SINGLE_REDEMPTION, MINIMUM_BASKET_TOTAL]
   * Each CONSTANT string points at a Class. This feels instinctively correct to
   * me, but I don't want to write a resolver.
   * I'm more pro this because I want (and I could be confused here) constraints
   * to be pure functions/functional? By this I mean given SPECIFIC_CUSTOMER Constraint
   * I don't want it to have a record of the customer, hmm maybe that's not related to
   * being functional.
   * I imagine:
   *
   * def valid?(submitted_customer: string, specified_customer: string)
   *   simple ===
   * end
   *
   * And it's the job of the end point to say, we have this Promotion, which has
   * SPECIFIC_CUSTOMER Constraint so I need to call valid? with the customer email
   * supplied from the request object and Promocode.customer_email. Seems wrong
   * for the Promotion to have knowledge of what must be passed to each Constraint :-/.
   * Do these need to be separate classes? Can they just be methods on Promotion?
   * Is it the responsibility of the Promotion to know what each constraint does/is?
   * I can imagine the Model becoming large if we get to 10+ constraints. Separate
   * Classes seems right, easier to unit test. Are there interactions between Constraints?
   * I hope not. Functional. I don't want one constraint to depend on another Constraint.
  constraints: string[]
}
```

```
Promocode {
  /*
   * e.g. MooLovesYou15 (case sensitive? Ask a marketing manager)
   * Code not unique. The *only* constraint is that you can't have two identical codes linked to
   * different promotions which have MultiUser Constraint and have overlapping running
   * dates (start_date -> end_date)
   * This should be validated by Promotion model before_create (I think)
   */
  code: string,
  /*
   * belongs_to Promotion
   */
  promotion_id: number,
  /*
   * has_many Redemption
   * NB this could only be 1 if the promotion has SINGLE_REDEMPTION Constraint.
   */
  redemption_ids: number[],
  /*
   * Not stored in the DB I don't think. Helper method on Model, shortcut for
   * Promocode.redemptions.count
   */
  redemption_count: number
  /*
   * customers are not a model (I don't think), users (AKA people using the API) need to supply
   * an email for a customer when setting up a promotion with the SPECIFIC_CUSTOMER Constraint
   */
  customer_email: string
}
```

## Marketing Manager web client
-**EMBER :-)**


# App :
## HomePage

- Header
  - Logo
  - SearchBar
      - Icon
      - Input
  - ShoppingCart
      - Icon
      - NotificationBadge
  - ClientButton (?)
      - Icon
      - Dropdown
      - DropdownItem
          - Icon
          - Link
- ProductCard (props => nom, image, prix, url du produit)
  - SubTitle 
  - Button
  - Link

## ProductDetailsPage

- Header
- ProductInfoSection
  - Title
  - SubTitle (props => color, label)
  - Ratings  (props => note)
  - Button
  - SelectQuantity
  - Paragraph (props => scrollable)
- ProductReviewSection
  - SubTitle 
  - RatingSummary
    - RatingSummaryLine (props => label, percentage)
      - ProgressBar (props => percentage)
  - CustomerReview
    - Icon
    - Ratings
    - Paragraph

## AuthenticatePage

- Header
- Form
    - SubTitle 
    - FormSection
      - Input
    - Button
    - Toggle (props => options, selectedOption)
      - Button

## ShoppingCartPage

- Header
- Title
- ProductListSection
  - ShoppingCartItem 
    - SubTitle 
    - SelectQuantity
    - IconButton
      - Icon
- TotalSection
  - SubTitle 
  - CodePromoLine
    - Input
    - Button
  - SubTitle
  - Button (props => size, text, color, disabled)

## CheckoutPage

- Header
- Title
- CommandOverview
  - SubTitle 
  - Button
- AddressForm (props => showCheckbox) 
  - Input
  - Checkbox
  - SubTitle 
  - Select
  - Button
- PaymentForm
  - SubTitle 
  - Select
- Button
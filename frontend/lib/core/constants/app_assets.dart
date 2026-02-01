class AppAssets {
  // Image paths
  static const String logo = 'assets/images/logo.png';
  static const String logoWhite = 'assets/images/logo_white.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String noImage = 'assets/images/no_image.png';
  static const String emptyCart = 'assets/images/empty_cart.png';
  static const String emptyOrders = 'assets/images/empty_orders.png';
  static const String emptyProducts = 'assets/images/empty_products.png';
  static const String errorImage = 'assets/images/error.png';
  static const String successImage = 'assets/images/success.png';
  
  // Icon paths
  static const String userIcon = 'assets/icons/user.svg';
  static const String adminIcon = 'assets/icons/admin.svg';
  static const String cartIcon = 'assets/icons/cart.svg';
  static const String productIcon = 'assets/icons/product.svg';
  static const String categoryIcon = 'assets/icons/category.svg';
  static const String orderIcon = 'assets/icons/order.svg';
  
  // Banner images
  static const String banner1 = 'assets/images/banners/banner1.jpg';
  static const String banner2 = 'assets/images/banners/banner2.jpg';
  static const String banner3 = 'assets/images/banners/banner3.jpg';
  
  // Category icons
  static const String electronics = 'assets/icons/categories/electronics.svg';
  static const String clothing = 'assets/icons/categories/clothing.svg';
  static const String books = 'assets/icons/categories/books.svg';
  static const String home = 'assets/icons/categories/home.svg';
  static const String sports = 'assets/icons/categories/sports.svg';
  static const String beauty = 'assets/icons/categories/beauty.svg';
  static const String food = 'assets/icons/categories/food.svg';
  static const String health = 'assets/icons/categories/health.svg';
  
  // Payment methods
  static const String visa = 'assets/icons/payment/visa.png';
  static const String mastercard = 'assets/icons/payment/mastercard.png';
  static const String paypal = 'assets/icons/payment/paypal.png';
  static const String cash = 'assets/icons/payment/cash.png';
  
  // Social media
  static const String facebook = 'assets/icons/social/facebook.png';
  static const String twitter = 'assets/icons/social/twitter.png';
  static const String instagram = 'assets/icons/social/instagram.png';
  static const String linkedin = 'assets/icons/social/linkedin.png';
  
  // Get category icon based on category name
  static String getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronics':
      case 'electronics & gadgets':
        return electronics;
      case 'clothing':
      case 'fashion':
      case 'apparel':
        return clothing;
      case 'books':
      case 'stationery':
        return books;
      case 'home':
      case 'home & garden':
      case 'furniture':
        return home;
      case 'sports':
      case 'fitness':
        return sports;
      case 'beauty':
      case 'cosmetics':
        return beauty;
      case 'food':
      case 'groceries':
        return food;
      case 'health':
      case 'wellness':
        return health;
      default:
        return categoryIcon;
    }
  }
  
  // Get payment method icon
  static String getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'visa':
        return visa;
      case 'mastercard':
        return mastercard;
      case 'paypal':
        return paypal;
      case 'cash':
      case 'cash on delivery':
        return cash;
      default:
        return cash;
    }
  }
  
  // Get social media icon
  static String getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return facebook;
      case 'twitter':
      case 'x':
        return twitter;
      case 'instagram':
        return instagram;
      case 'linkedin':
        return linkedin;
      default:
        return facebook;
    }
  }
}
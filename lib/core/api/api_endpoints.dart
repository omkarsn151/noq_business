class ApiEndpoints {
  ApiEndpoints._();

  static const String baseurl = "http://3.111.20.58/api/";

  //====================Auth====================

  //request-otp
  static const String requestOtp = "v1/auth/otp/request";

  //verify-otp
  static const String verifyOtp = "v1/auth/otp/verify";

  //refresh-token
  static const String refreshToken = "v1/auth/token/refresh";

  //update-name
  static const String updateName = "v1/auth/profile";

  //====================BusinessSetup====================

  static const String createBusinesses = "v1/business/profile";

  static const String submitBusinessForReview =
      "v1/business/submit-for-review";

  //====================Categories====================

  static const String getCategories = "v1/categories";

  static const String getSubCategories = "v1/business/sub-categories";

  //====================Services====================

  static const String getServices = "v1/business/services";

  static const String addService = "v1/business/services";

  static const String deleteService = "v1/business/services";

  static const String editService = "v1/business/services";

  //====================Staff====================

  static const String getStaff = "v1/business/staff";

  static const String addStaff = "v1/business/staff";

  static const String deleteStaff = "v1/business/staff";

  static const String editStaff = "v1/business/staff";


  static const String staffDetails = "v1/business/staff";

  //====================Uplaod====================

  static const String upload = "v1/uploads";

  static const String deleteUpload = "v1/uploads/";

  //====================Business====================

  static const String getBusinessData = "v1/business";

  //====================Business====================

  static const String getReviewStatus = "v1/business/review-status";


  //====================Promotions====================
  static const String getPromotions = "v1/business/promos";

  static const String createPromotion = "v1/business/promos";

  static const String getPromotionDetails = "v1/business/promos/";

  // id appended by caller
  static const String updatePromotion = "v1/business/promos/";

  //====================Bookings====================
  static const String getBookings = "v1/business/bookings";

  static const String getBookingDetails = "v1/business/bookings/";

  static const String getTodaysBookings = "v1/business/bookings/today";

  //====================Walkin====================
  static const String getWalkinSlots = "v1/business/walk-ins/slots";

  static const String createWalkin = "v1/business/walk-ins";

  //====================Dashboard====================
  static const String getDashboard = "v1/business/dashboard";

  //====================Business Profile Overview====================
  static const String getBusinessOverview = "v1/business/overview";

  static const String getBusinessGallery = "v1/business/gallery";

  static const String getBusinessSettings = "v1/business/operations";

  static const String updateBusinessSettings = "v1/business/operations";

  //====================Ratings and Reviews====================
  static const String getRatingsAndReviews = "v1/business/reviews";

  //====================Insights====================
  static const String getInsights = "v1/business/insights";

}

/// Company Info Model
class CompanyInfoModel {
  final String name;
  final String? tagline;
  final String? description;
  final String? about;
  final String? email;
  final String? phone;
  final String? alternatePhone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? website;
  final String? logoUrl;
  final String? logoLightUrl;
  final String? logoDarkUrl;
  final String? faviconUrl;
  final SocialLinks? socialLinks;
  final BusinessHours? businessHours;
  final String? gstNumber;
  final String? panNumber;
  final String? registrationNumber;
  final Map<String, dynamic>? rawData;

  CompanyInfoModel({
    required this.name,
    this.tagline,
    this.description,
    this.about,
    this.email,
    this.phone,
    this.alternatePhone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.website,
    this.logoUrl,
    this.logoLightUrl,
    this.logoDarkUrl,
    this.faviconUrl,
    this.socialLinks,
    this.businessHours,
    this.gstNumber,
    this.panNumber,
    this.registrationNumber,
    this.rawData,
  });

  factory CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    return CompanyInfoModel(
      name: json['name'] ?? json['company_name'] ?? json['companyName'] ?? 'Company',
      tagline: json['tagline'] ?? json['slogan'],
      description: json['description'],
      about: json['about'] ?? json['about_us'],
      email: json['email'] ?? json['company_email'],
      phone: json['phone'] ?? json['company_phone'] ?? json['mobile'],
      alternatePhone: json['alternate_phone'] ?? json['alt_phone'],
      address: json['address'] ?? json['company_address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'] ?? json['zip_code'] ?? json['pincode'],
      website: json['website'] ?? json['company_website'],
      logoUrl: json['logo_url'] ?? json['logo'],
      logoLightUrl: json['logo_light_url'] ?? json['logo_light'],
      logoDarkUrl: json['logo_dark_url'] ?? json['logo_dark'],
      faviconUrl: json['favicon_url'] ?? json['favicon'],
      socialLinks: json['social_links'] != null || json['social'] != null
          ? SocialLinks.fromJson(json['social_links'] ?? json['social'] ?? json)
          : null,
      businessHours: json['business_hours'] != null
          ? BusinessHours.fromJson(json['business_hours'])
          : null,
      gstNumber: json['gst_number'] ?? json['gstin'],
      panNumber: json['pan_number'] ?? json['pan'],
      registrationNumber: json['registration_number'] ?? json['reg_number'],
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tagline': tagline,
      'description': description,
      'about': about,
      'email': email,
      'phone': phone,
      'alternate_phone': alternatePhone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'website': website,
      'logo_url': logoUrl,
      'logo_light_url': logoLightUrl,
      'logo_dark_url': logoDarkUrl,
      'favicon_url': faviconUrl,
      'social_links': socialLinks?.toJson(),
      'business_hours': businessHours?.toJson(),
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'registration_number': registrationNumber,
    };
  }

  factory CompanyInfoModel.defaults() {
    return CompanyInfoModel(
      name: 'Distributor App',
      tagline: 'Your B2B Distribution Partner',
    );
  }

  /// Get full address
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Get logo for theme
  String? getLogoForTheme(bool isDark) {
    if (isDark && logoDarkUrl != null) return logoDarkUrl;
    if (!isDark && logoLightUrl != null) return logoLightUrl;
    return logoUrl;
  }
}

/// Social Links
class SocialLinks {
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? linkedin;
  final String? youtube;
  final String? whatsapp;
  final String? telegram;
  final String? pinterest;
  final String? tiktok;

  SocialLinks({
    this.facebook,
    this.twitter,
    this.instagram,
    this.linkedin,
    this.youtube,
    this.whatsapp,
    this.telegram,
    this.pinterest,
    this.tiktok,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      facebook: json['facebook'] ?? json['facebook_url'],
      twitter: json['twitter'] ?? json['twitter_url'] ?? json['x'],
      instagram: json['instagram'] ?? json['instagram_url'],
      linkedin: json['linkedin'] ?? json['linkedin_url'],
      youtube: json['youtube'] ?? json['youtube_url'],
      whatsapp: json['whatsapp'] ?? json['whatsapp_number'],
      telegram: json['telegram'] ?? json['telegram_url'],
      pinterest: json['pinterest'] ?? json['pinterest_url'],
      tiktok: json['tiktok'] ?? json['tiktok_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'twitter': twitter,
      'instagram': instagram,
      'linkedin': linkedin,
      'youtube': youtube,
      'whatsapp': whatsapp,
      'telegram': telegram,
      'pinterest': pinterest,
      'tiktok': tiktok,
    };
  }

  /// Get all available links as map
  Map<String, String> get availableLinks {
    final links = <String, String>{};
    if (facebook != null) links['facebook'] = facebook!;
    if (twitter != null) links['twitter'] = twitter!;
    if (instagram != null) links['instagram'] = instagram!;
    if (linkedin != null) links['linkedin'] = linkedin!;
    if (youtube != null) links['youtube'] = youtube!;
    if (whatsapp != null) links['whatsapp'] = whatsapp!;
    if (telegram != null) links['telegram'] = telegram!;
    if (pinterest != null) links['pinterest'] = pinterest!;
    if (tiktok != null) links['tiktok'] = tiktok!;
    return links;
  }

  /// Check if has any social links
  bool get hasAny => availableLinks.isNotEmpty;
}

/// Business Hours
class BusinessHours {
  final String? monday;
  final String? tuesday;
  final String? wednesday;
  final String? thursday;
  final String? friday;
  final String? saturday;
  final String? sunday;
  final String? timezone;

  BusinessHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
    this.timezone,
  });

  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    return BusinessHours(
      monday: json['monday'] ?? json['mon'],
      tuesday: json['tuesday'] ?? json['tue'],
      wednesday: json['wednesday'] ?? json['wed'],
      thursday: json['thursday'] ?? json['thu'],
      friday: json['friday'] ?? json['fri'],
      saturday: json['saturday'] ?? json['sat'],
      sunday: json['sunday'] ?? json['sun'],
      timezone: json['timezone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday,
      'tuesday': tuesday,
      'wednesday': wednesday,
      'thursday': thursday,
      'friday': friday,
      'saturday': saturday,
      'sunday': sunday,
      'timezone': timezone,
    };
  }

  /// Get hours for current day
  String? get todayHours {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1:
        return monday;
      case 2:
        return tuesday;
      case 3:
        return wednesday;
      case 4:
        return thursday;
      case 5:
        return friday;
      case 6:
        return saturday;
      case 7:
        return sunday;
      default:
        return null;
    }
  }

  /// Check if open today
  bool get isOpenToday => todayHours != null && todayHours!.toLowerCase() != 'closed';
}

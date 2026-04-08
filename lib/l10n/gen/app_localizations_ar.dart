// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get all => 'الكل';

  @override
  String get allProjects => 'جميع المشاريع';

  @override
  String get appTitle => 'فوتيرا';

  @override
  String get appTagline => 'اكتشف، صوّت، واحتفل\nبالمشاريع المبتكرة.';

  @override
  String get appMotto => 'اكتشف. صوّت. احتفل.';

  @override
  String get home => 'الرئيسية';

  @override
  String get teams => 'الفرق';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get fullNameTooLong => 'يجب ألا يتجاوز الاسم الكامل 100 حرف';

  @override
  String get aboutUs => 'عن التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get verifyAccount => 'توثيق الحساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get signingIn => 'جارٍ تسجيل الدخول...';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get joinExhibition => 'انضم إلى المعرض وابدأ التصويت';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get enterFullName => 'أدخل اسمك الكامل';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get identifier => 'المعرّف';

  @override
  String get enterIdentifier => 'أدخل بريدك الإلكتروني أو اسم المستخدم';

  @override
  String get identifierRequired => 'المعرّف مطلوب';

  @override
  String get createPassword => 'أنشئ كلمة مرور';

  @override
  String get creatingAccount => 'جارٍ إنشاء الحساب...';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get signInToVote => 'سجّل دخولك للتصويت على مشاريعك المفضلة';

  @override
  String get yourRole => 'دورك';

  @override
  String get student => 'طالب';

  @override
  String get professor => 'أستاذ';

  @override
  String get visitor => 'زائر';

  @override
  String get department => 'القسم';

  @override
  String get departmentHint => 'علوم الحاسوب';

  @override
  String get universityIdOptional => 'الرقم الجامعي (اختياري)';

  @override
  String get universityIdHint => '2024001234';

  @override
  String get phoneOptional => 'رقم الهاتف (اختياري)';

  @override
  String get phoneHint => '+964 xxx xxx xxxx';

  @override
  String get continueButton => 'متابعة';

  @override
  String get tellUsAboutYou => 'أخبرنا عن نفسك';

  @override
  String get personalizeExperience => 'سنخصّص تجربة المعرض بناءً على معلوماتك';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordDesc =>
      'أدخل بريدك الإلكتروني وسنرسل لك رمز إعادة التعيين.';

  @override
  String get sending => 'جارٍ الإرسال...';

  @override
  String get sendResetLink => 'إرسال رمز الإعادة';

  @override
  String get checkYourEmail => 'تحقق من بريدك الإلكتروني';

  @override
  String resetLinkSent(String email) {
    return 'أرسلنا رمز إعادة تعيين كلمة المرور إلى\n$email';
  }

  @override
  String get confirmResetTitle => 'تعيين كلمة مرور جديدة';

  @override
  String get confirmResetDesc =>
      'الصق الرمز من بريدك الإلكتروني وأدخل كلمة مرور جديدة.';

  @override
  String get resetToken => 'رمز الإعادة';

  @override
  String get pasteToken => 'الصق الرمز من البريد الإلكتروني';

  @override
  String get tokenRequired => 'الرمز مطلوب';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get enterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get newPasswordRequired => 'كلمة المرور الجديدة مطلوبة';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أعد إدخال كلمة المرور الجديدة';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get resetting => 'جارٍ الإعادة...';

  @override
  String get setNewPassword => 'تعيين كلمة المرور';

  @override
  String get passwordResetSuccess =>
      'تم إعادة تعيين كلمة المرور. يرجى تسجيل الدخول.';

  @override
  String get verifyYourAccount => 'توثيق حسابك';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق';

  @override
  String get codeSentTo => 'أرسلنا رمزًا مكوّنًا من 6 أرقام إلى';

  @override
  String get verifying => 'جارٍ التحقق...';

  @override
  String get verify => 'تحقق';

  @override
  String get categories => 'الفئات';

  @override
  String get browseByCategory => 'تصفح المشاريع حسب الفئة';

  @override
  String get aiMl => 'ذكاء اصطناعي / تعلم آلي';

  @override
  String get webDev => 'تطوير الويب';

  @override
  String get mobileApps => 'تطبيقات الجوال';

  @override
  String get game => 'ألعاب';

  @override
  String get iot => 'إنترنت الأشياء';

  @override
  String get data => 'البيانات';

  @override
  String projectCount(int count) {
    return '$count مشروع';
  }

  @override
  String get discoverOnboarding => 'اكتشف المشاريع';

  @override
  String get discoverOnboardingDesc =>
      'تصفح مشاريع برمجية مبتكرة من إنشاء طلاب الجامعة.';

  @override
  String get rateVote => 'قيّم وصوّت';

  @override
  String get rateVoteDesc => 'صوّت لمشاريعك المفضلة وساعد في اختيار الفائزين.';

  @override
  String get celebrateWinners => 'احتفل بالفائزين';

  @override
  String get celebrateWinnersDesc =>
      'اطّلع على المشاريع الرائجة واحتفل بأكثرها تصويتًا.';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get exhibitions => 'فوتيرا';

  @override
  String get exploreExhibitions => 'استكشف المعارض والفعاليات';

  @override
  String get noEventsYet => 'لا توجد فعاليات بعد';

  @override
  String get noEventsDesc =>
      'لا تتوفر معارض أو فعاليات في الوقت الحالي. تحقق لاحقًا.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get exhibition => 'المعرض';

  @override
  String get projects => 'المشاريع';

  @override
  String get rankings => 'التصنيفات';

  @override
  String get myProject => 'مشروعي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات بعد';

  @override
  String get noNotificationsDesc =>
      'ستظهر هنا تحديثات الفعاليات والتصويتات والنتائج.';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get earlier => 'سابقًا';

  @override
  String get universityIdCard => 'بطاقة الهوية الجامعية';

  @override
  String get uploadIdDesc => 'يرجى رفع صورة هويتك الجامعية.';

  @override
  String get requestPending => 'تم تقديم الطلب — في انتظار المراجعة.';

  @override
  String get myRequests => 'طلباتي';

  @override
  String get submitNewRequest => 'تقديم طلب جديد';

  @override
  String get fillIdForm => 'أدخل بياناتك وارفع صورة واضحة لهويتك الجامعية.';

  @override
  String get nameAsOnId => 'كما هو مدوّن في الهوية';

  @override
  String get universityId => 'الرقم الجامعي';

  @override
  String get universityIdExample => 'CS2021001';

  @override
  String get universityIdRequired => 'الرقم الجامعي مطلوب';

  @override
  String get universityIdTooShort => 'يجب أن يكون الرقم 3 أحرف على الأقل';

  @override
  String get departmentRequired => 'القسم مطلوب';

  @override
  String get stageYear => 'المرحلة / السنة';

  @override
  String get stageYearExample => 'السنة الثالثة';

  @override
  String get stageRequired => 'المرحلة مطلوبة';

  @override
  String get tapToUploadId => 'اضغط لرفع الهوية';

  @override
  String get submitting => 'جارٍ الإرسال...';

  @override
  String get submitRequest => 'تقديم الطلب';

  @override
  String get approved => 'موافق عليه';

  @override
  String get rejected => 'مرفوض';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String noteLabel(String note) {
    return 'ملاحظة: $note';
  }

  @override
  String get chooseVerificationMethod => 'اختر طريقة التوثيق';

  @override
  String get verificationUnlocks =>
      'يمنحك توثيق حسابك وصولًا كاملًا إلى جميع الميزات.';

  @override
  String get institutionalEmail => 'البريد المؤسسي';

  @override
  String get verifyWithEmail =>
      'تحقق باستخدام بريدك الجامعي.\nستحصل على رمز OTP مكوّن من 6 أرقام فورًا.';

  @override
  String get instant => 'فوري';

  @override
  String get uploadIdCard => 'ارفع صورة هويتك الجامعية.\nسيراجعها المسؤول.';

  @override
  String get requiresReview => 'يتطلب مراجعة';

  @override
  String get enterInstitutionalEmail => 'أدخل بريدك المؤسسي';

  @override
  String get institutionalEmailDesc =>
      'سنرسل رمز تحقق مكوّنًا من 6 أرقام إلى بريدك الجامعي.';

  @override
  String get institutionalEmailHint => 'your.name@university.edu';

  @override
  String get sendOtp => 'إرسال الرمز';

  @override
  String get accountVerified => 'تم توثيق الحساب! تم منح دور المشارك.';

  @override
  String get communityFeedback => 'آراء المجتمع';

  @override
  String get aboutProject => 'عن هذا المشروع';

  @override
  String get techStack => 'التقنيات المستخدمة';

  @override
  String get projectLinks => 'روابط المشروع';

  @override
  String get sourceCode => 'الكود المصدري';

  @override
  String get liveDemo => 'عرض مباشر';

  @override
  String get communityRating => 'تقييم المجتمع';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String ratingCount(int totalRatings) {
    return '$totalRatings تقييم';
  }

  @override
  String get rateThisProject => 'قيّم هذا المشروع';

  @override
  String get tapStarToRate => 'اضغط على نجمة لمشاركة تقييمك';

  @override
  String get writeYourReview => 'اكتب مراجعتك (اختياري)';

  @override
  String get selectStarFirst => 'يرجى اختيار تقييم بالنجوم قبل الإرسال.';

  @override
  String get loadMoreComments => 'تحميل المزيد من التعليقات';

  @override
  String get comments => 'التعليقات';

  @override
  String get addComment => 'أضف تعليقًا...';

  @override
  String get noCommentsYet => 'لا توجد تعليقات بعد. كن أول من يعلّق!';

  @override
  String get statusSubmitted => 'مقدَّم';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get yourVotes => 'تصويتاتك';

  @override
  String get votesCast => 'أصوات مُدلى بها';

  @override
  String get rated => 'مُقيَّم';

  @override
  String get pullToRefresh => 'اسحب للأسفل للتحديث';

  @override
  String get vote => 'تصويت';

  @override
  String get voteSuccess => 'تم تسجيل تصويتك!';

  @override
  String get imageTooLarge =>
      'الصورة كبيرة جداً. يرجى اختيار صورة أقل من 5 ميغابايت.';

  @override
  String get voted => 'تم التصويت';

  @override
  String get trending => 'رائج';

  @override
  String get winner => 'فائز';

  @override
  String voteCount(int voteCount) {
    return '$voteCount صوت';
  }

  @override
  String get myTeam => 'فريقي';

  @override
  String get browse => 'تصفح';

  @override
  String get invitationSent => 'تم إرسال الدعوة بنجاح.';

  @override
  String get leaveTeam => 'مغادرة الفريق';

  @override
  String get inviteMember => 'دعوة عضو';

  @override
  String get enterUserIdToInvite => 'أدخل معرّف المستخدم للدعوة';

  @override
  String get sendInvite => 'إرسال الدعوة';

  @override
  String get removeMember => 'إزالة العضو';

  @override
  String get removeMemberConfirm => 'هل أنت متأكد من إزالة هذا العضو من فريقك؟';

  @override
  String get remove => 'إزالة';

  @override
  String get noMembersForLeadership =>
      'لا يوجد أعضاء آخرون لنقل القيادة إليهم.';

  @override
  String get transferLeadership => 'نقل القيادة';

  @override
  String get selectNewLeader => 'اختر العضو الذي سيصبح قائد الفريق.';

  @override
  String get transferLeadershipFirst =>
      'انقل القيادة إلى عضو آخر قبل المغادرة.';

  @override
  String get leaveAndDelete => 'مغادرة وحذف الفريق';

  @override
  String leaveAndDeleteDesc(String name) {
    return 'أنت العضو الوحيد. ستؤدي المغادرة إلى حذف \"$name\" نهائيًا. لا يمكن التراجع.';
  }

  @override
  String get leaveAndDeleteButton => 'مغادرة وحذف';

  @override
  String get leaveTeamConfirm =>
      'هل أنت متأكد من مغادرة فريقك؟ يمكنك الانضمام إلى فريق آخر أو إنشاء فريق جديد لاحقًا.';

  @override
  String get leave => 'مغادرة';

  @override
  String get deleteTeam => 'حذف الفريق';

  @override
  String deleteTeamDesc(String name) {
    return 'سيؤدي هذا إلى حذف \"$name\" نهائيًا وإزالة جميع الأعضاء. لا يمكن التراجع.';
  }

  @override
  String get findATeam => 'البحث عن فريق';

  @override
  String get findATeamDesc =>
      'ابحث باسم الفريق لاكتشاف الفرق الموجودة والانضمام إليها.';

  @override
  String get noTeamsFound => 'لم يُعثر على فرق';

  @override
  String noTeamsMatchedQuery(String query) {
    return 'لا توجد فرق تطابق \"$query\". جرّب اسمًا آخر.';
  }

  @override
  String get leader => 'القائد';

  @override
  String memberCount(int count) {
    return '$count عضو';
  }

  @override
  String membersWithCount(int count) {
    return 'الأعضاء ($count)';
  }

  @override
  String get pendingInvitations => 'الدعوات المعلّقة';

  @override
  String get teamSettings => 'إعدادات الفريق';

  @override
  String get editTeamInfo => 'تعديل معلومات الفريق';

  @override
  String get changeTeamNameDesc => 'تغيير اسم الفريق أو وصفه';

  @override
  String get assignNewLeader => 'تعيين قائد جديد للفريق';

  @override
  String get permanentlyDisband => 'حلّ الفريق نهائيًا';

  @override
  String get leaveTeamOnlyMember => 'إذا كنت العضو الوحيد، سيُحذف الفريق';

  @override
  String get notInTeamYet => 'لست في فريق بعد';

  @override
  String get createOrJoinTeam =>
      'أنشئ فريقك الخاص أو تصفح الفرق الموجودة للانضمام.';

  @override
  String get createATeam => 'إنشاء فريق';

  @override
  String get browseTeams => 'تصفح الفرق';

  @override
  String get invite => 'دعوة';

  @override
  String get searchTeamsByName => 'البحث عن الفرق بالاسم...';

  @override
  String get cancel => 'إلغاء';

  @override
  String get about => 'عن الفريق';

  @override
  String get tryAgain => 'حاول مجددًا';

  @override
  String get open => 'مفتوح';

  @override
  String get voting => 'التصويت';

  @override
  String get upcoming => 'قادم';

  @override
  String get closed => 'مغلق';

  @override
  String get archived => 'مؤرشف';

  @override
  String get submissionsOpen => 'التقديم مفتوح';

  @override
  String get voteNow => 'صوّت الآن';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get ended => 'انتهى';

  @override
  String teamSizeRange(int minSize, int maxSize) {
    return '$minSize-$maxSize أعضاء';
  }

  @override
  String teamSizeMin(int minSize) {
    return '$minSize+ أعضاء';
  }

  @override
  String teamSizeMax(int maxSize) {
    return 'حتى $maxSize';
  }

  @override
  String maxVotes(int maxVotes) {
    return '$maxVotes أصوات';
  }

  @override
  String get teamInvitation => 'دعوة للفريق';

  @override
  String teamLabel(String teamId) {
    return 'الفريق: $teamId';
  }

  @override
  String invitedBy(String inviter) {
    return 'دعاك: $inviter';
  }

  @override
  String get decline => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String get userFallback => 'مستخدم';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    return 'منذ $count د';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count س';
  }

  @override
  String daysAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get projectTeam => 'الفريق';

  @override
  String get rankingsSupervisorTab => 'المشرف';

  @override
  String get rankingsStudentTab => 'الطالب';

  @override
  String get rankingsVisitorTab => 'الزائر';

  @override
  String get noRankingsYet => 'لا توجد تصنيفات بعد';

  @override
  String get rankingsWillAppear => 'ستظهر التصنيفات عند بدء التصويت.';

  @override
  String get rankingsLabel => 'التصنيفات';

  @override
  String get votesLabel => 'صوت';

  @override
  String votesWithCount(int count) {
    return '$count صوت';
  }

  @override
  String get noCategoriesYet => 'لا توجد فئات بعد';

  @override
  String get noCategoriesDesc => 'لا تتوفر فئات لهذه الفعالية.';

  @override
  String get youSuffix => '(أنت)';

  @override
  String joinedDate(String date) {
    return 'انضم في $date';
  }

  @override
  String get removeMemberTooltip => 'إزالة العضو';

  @override
  String get invitationSentSuccess => 'تم إرسال الدعوة بنجاح.';

  @override
  String get editTeamInfoTitle => 'تعديل معلومات الفريق';

  @override
  String get transferLeadershipTitle => 'نقل القيادة';

  @override
  String get deleteTeamTitle => 'حذف الفريق';

  @override
  String get leaveTeamTitle => 'مغادرة الفريق';

  @override
  String get delete => 'حذف';

  @override
  String get deleteTeamImage => 'إزالة صورة الفريق';

  @override
  String get deleteTeamImageConfirm => 'هل أنت متأكد من إزالة صورة الفريق؟';

  @override
  String get needATeamFirst => 'تحتاج إلى فريق أولاً';

  @override
  String get needATeamDesc =>
      'أنشئ فريقًا أو انضم إلى فريق قبل تقديم مشروعك في هذه الفعالية.';

  @override
  String get selectTeamTitle => 'اختر فريقاً';

  @override
  String get selectTeamDesc =>
      'أنت عضو في أكثر من فريق. اختر الفريق الذي سيقدّم هذا المشروع.';

  @override
  String get changeTeam => 'تغيير';

  @override
  String get submittingAsTeam => 'التقديم باسم';

  @override
  String get submitYourProject => 'أرسل مشروعك';

  @override
  String get submitYourProjectDesc =>
      'أدخل التفاصيل أدناه لتسجيل مشروعك في هذه الفعالية.';

  @override
  String get projectTitle => 'عنوان المشروع *';

  @override
  String get projectTitleHint => 'نظام الري الذكي';

  @override
  String get projectTitleRequired => 'العنوان مطلوب';

  @override
  String get projectTitleTooShort => 'يجب أن يكون العنوان 3 أحرف على الأقل';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get descriptionHint => 'ماذا يفعل مشروعك؟';

  @override
  String get techStackLabel => 'التقنيات المستخدمة';

  @override
  String get techStackHint => 'Flutter, Firebase, Python';

  @override
  String get repositoryUrl => 'رابط المستودع';

  @override
  String get repositoryUrlHint => 'https://github.com/...';

  @override
  String get demoUrl => 'رابط العرض التجريبي';

  @override
  String get demoUrlHint => 'https://...';

  @override
  String get submitProject => 'تقديم المشروع';

  @override
  String get editProject => 'تعديل المشروع';

  @override
  String get editProjectDesc => 'حدّث تفاصيل مشروعك أدناه.';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get viewProject => 'عرض';

  @override
  String get noLinksAdded => 'لا توجد روابط مضافة بعد';

  @override
  String get repositoryChip => 'المستودع';

  @override
  String get demoChip => 'عرض';

  @override
  String get createdLabel => 'تاريخ الإنشاء';

  @override
  String get draftStatusBanner => 'مسودة — لم يُرسَل بعد للمراجعة';

  @override
  String get submittedStatusBanner => 'مُقدَّم — في انتظار مراجعة المنظم';

  @override
  String get acceptedStatusBanner => 'مقبول — تمت الموافقة على مشروعك';

  @override
  String get rejectedStatusBanner => 'مرفوض — تحقق من ملاحظات المنظم';

  @override
  String get editProjectButton => 'تعديل المشروع';

  @override
  String get submitForReview => 'إرسال للمراجعة';

  @override
  String get cancelSubmission => 'إلغاء التقديم';

  @override
  String get submitForReviewTitle => 'إرسال للمراجعة؟';

  @override
  String get submitForReviewDesc =>
      'سيُرسَل مشروعك إلى المنظمين للمراجعة. يمكنك إلغاء التقديم في أي وقت قبل المراجعة.';

  @override
  String get notYet => 'ليس بعد';

  @override
  String get submit => 'إرسال';

  @override
  String get cancelSubmissionTitle => 'إلغاء التقديم؟';

  @override
  String get cancelSubmissionDesc =>
      'سيُعاد مشروعك إلى المسودة. يمكنك إعادة التقديم في أي وقت.';

  @override
  String get keepSubmitted => 'إبقاء مُقدَّمًا';

  @override
  String get cancelSubmissionButton => 'إلغاء التقديم';

  @override
  String get editTeamTitle => 'تعديل الفريق';

  @override
  String get editTeamDesc => 'حدّث تفاصيل فريقك أدناه.';

  @override
  String get createTeamDesc => 'امنح فريقك اسمًا ووصفًا اختياريًا.';

  @override
  String get teamName => 'اسم الفريق';

  @override
  String get teamHandle => 'معرّف الفريق';

  @override
  String get memberName => 'اسم العضو';

  @override
  String get userId => 'معرّف المستخدم';

  @override
  String get teamNameHint => 'المبتكرون';

  @override
  String get teamNameRequired => 'اسم الفريق مطلوب';

  @override
  String get teamNameTooShort => 'يجب أن يكون الاسم 3 أحرف على الأقل';

  @override
  String get teamDescriptionOptional => 'الوصف (اختياري)';

  @override
  String get teamDescriptionHint => 'ماذا يفعل فريقك؟';

  @override
  String get createTeamButton => 'إنشاء فريق';

  @override
  String get noProjectsYet => 'لا توجد مشاريع بعد';

  @override
  String get noProjectsDesc => 'لا توجد مشاريع مقدمة لهذه الفعالية بعد.';

  @override
  String get noProjectsInCategory => 'لا توجد مشاريع في هذا التصنيف';

  @override
  String get noProjectsInCategoryDesc =>
      'لم يتم تصنيف أي مشاريع ضمن هذا التصنيف بعد.';

  @override
  String get noProjectsFound => 'لم يتم العثور على مشاريع';

  @override
  String get noProjectsFoundDesc =>
      'لا توجد مشاريع تطابق بحثك. جرّب عنواناً مختلفاً.';

  @override
  String get searchProjectsTeams => 'ابحث عن مشاريع أو فرق...';

  @override
  String get trendingNow => 'رائج الآن';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get heyThere => 'مرحبًا!';

  @override
  String get springHackathon => 'هاكاثون الربيع';

  @override
  String get thePrefix => '';

  @override
  String get orContinueWith => 'أو المتابعة عبر';

  @override
  String get waitingForTelegram => 'جارٍ انتظار تيليغرام...';

  @override
  String get continueWithTelegram => 'المتابعة عبر تيليغرام';

  @override
  String get settings => 'الإعدادات';

  @override
  String get copiedToClipboard => 'تم النسخ';

  @override
  String get createdAt => 'تاريخ الإنشاء';

  @override
  String get whoAreYou => 'من أنت؟';

  @override
  String get chooseRoleToVerify => 'اختر دورك لتوثيق حسابك الجامعي.';

  @override
  String get iAmStudent => 'أنا طالب';

  @override
  String get studentEmailExample => '5920220096@student.uokufa.edu.iq';

  @override
  String get iAmTeacher => 'أنا أستاذ / مشرف';

  @override
  String get teacherEmailExample => 'ahmedh.almajidy@uokufa.edu.iq';

  @override
  String get studentEmailDomainError =>
      'يجب أن يكون بريدًا جامعيًا للطلاب (@student.uokufa.edu.iq)';

  @override
  String get teacherEmailDomainError =>
      'يجب أن يكون بريد مشرف (@uokufa.edu.iq)';

  @override
  String get teacherEmailNotStudent => 'بريد الأستاذ لا يمكن أن يكون بريد طالب';

  @override
  String get supervisorEmail => 'بريد المشرف';

  @override
  String get enterSupervisorEmail => 'أدخل بريد المشرف';

  @override
  String get supervisorEmailDesc =>
      'سنرسل رمز تحقق مكوّنًا من 6 أرقام إلى بريد المشرف الخاص بك.';

  @override
  String get supervisorEmailHint => 'your.name@uokufa.edu.iq';

  @override
  String get supervisorAccountVerified => 'تم توثيق الحساب! تم منح دور المشرف.';

  @override
  String get studentVerified => 'طالب موثق';

  @override
  String get teacherVerified => 'أستاذ موثق';

  @override
  String get telegramVerified => 'موثق عبر تيليغرام';

  @override
  String get requestToJoin => 'طلب الانضمام';

  @override
  String get joinRequestSent => 'تم إرسال طلب انضمامك.';

  @override
  String get joinRequestMessage => 'رسالة (اختياري)';

  @override
  String get joinRequestMessageHint =>
      'عرّف بنفسك أو اشرح سبب رغبتك في الانضمام...';

  @override
  String get joinRequests => 'طلبات الانضمام';

  @override
  String get noJoinRequests => 'لا توجد طلبات انضمام معلقة.';

  @override
  String get approveRequest => 'قبول';

  @override
  String get declineRequest => 'رفض';

  @override
  String get shareProjectSubject => 'شاهد هذا المشروع على Votera!';

  @override
  String get shareProjectMessage =>
      'وجدت مشروعاً مثيراً للاهتمام على Votera. اضغط الرابط لعرضه:';

  @override
  String get votingPhaseTitle => 'التصويت جارٍ';

  @override
  String get votingPhaseDesc => 'انتهى وقت تقديم المشاريع. المجتمع يصوّت الآن.';

  @override
  String get eventClosedTitle => 'انتهى الحدث';

  @override
  String get eventClosedDesc =>
      'هذا الحدث مغلق ولا يقبل تقديم المشاريع بعد الآن.';

  @override
  String get eventNotStartedTitle => 'لم يبدأ الحدث بعد';

  @override
  String get eventNotStartedDesc =>
      'لم يُفتح باب التقديم لهذا الحدث بعد. تحقق لاحقاً.';

  @override
  String get eventArchivedTitle => 'تم أرشفة الحدث';

  @override
  String get eventArchivedDesc => 'تم أرشفة هذا الحدث وهو لم يعد نشطاً.';

  @override
  String get basicInfoCard => 'المعلومات الأساسية';

  @override
  String get techLinksCard => 'التقنيات والروابط';

  @override
  String get categoriesCard => 'التصنيفات';

  @override
  String get categoriesCardDesc => 'اختر من 1 إلى 3 تصنيفات تصف مشروعك.';

  @override
  String get selectCategory => 'اختر تصنيفاً';

  @override
  String get addCategory => 'إضافة تصنيف';

  @override
  String get categoryAdded => 'تمت إضافة التصنيف';

  @override
  String get categoryRemoved => 'تمت إزالة التصنيف';

  @override
  String get maxCategoriesHint => 'يمكنك اختيار 3 تصنيفات كحد أقصى.';

  @override
  String get noCategoriesAvailable => 'لا توجد تصنيفات متاحة';

  @override
  String get noCategoriesSelected => 'لم يتم اختيار أي تصنيف بعد';

  @override
  String get projectImagesCard => 'صور المشروع';

  @override
  String get coverImageFormHint => 'أضف صورة غلاف لإبراز مشروعك.';

  @override
  String get tapToAddCover => 'اضغط لإضافة صورة غلاف';

  @override
  String get extraImagesNote => 'يمكنك إضافة المزيد من الصور بعد الإرسال.';

  @override
  String get editProjectTitle => 'تعديل المشروع';

  @override
  String get editProjectSubtitle => 'حدّث تفاصيل مشروعك وصوره وتصنيفاته.';

  @override
  String get saveProject => 'حفظ التغييرات';

  @override
  String get projectGallery => 'معرض المشروع';

  @override
  String get projectImages => 'صور المشروع';

  @override
  String get coverImage => 'صورة الغلاف';

  @override
  String get addCoverImage => 'إضافة صورة غلاف';

  @override
  String get changeCoverImage => 'تغيير';

  @override
  String get extraImages => 'صور إضافية';

  @override
  String get addExtraImage => 'إضافة صورة';

  @override
  String get removeImage => 'حذف';

  @override
  String get confirmRemoveCoverTitle => 'حذف صورة الغلاف؟';

  @override
  String get confirmRemoveCoverDesc => 'سيتم حذف صورة الغلاف نهائياً.';

  @override
  String get confirmRemoveImageTitle => 'حذف الصورة؟';

  @override
  String get confirmRemoveImageDesc => 'سيتم حذف هذه الصورة نهائياً.';

  @override
  String get deleteProject => 'حذف المشروع';

  @override
  String get confirmDeleteProjectTitle => 'حذف المشروع؟';

  @override
  String get confirmDeleteProjectDesc =>
      'سيتم حذف مشروعك وجميع صوره نهائياً. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get forceUpdateTitle => 'تحديث مطلوب';

  @override
  String get forceUpdateButton => 'تحميل التحديث';
}

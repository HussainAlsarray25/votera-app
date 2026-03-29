import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allProjects.
  ///
  /// In en, this message translates to:
  /// **'All Projects'**
  String get allProjects;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Votera'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Discover, vote, and celebrate\ninnovative projects.'**
  String get appTagline;

  /// No description provided for @appMotto.
  ///
  /// In en, this message translates to:
  /// **'Discover. Vote. Celebrate.'**
  String get appMotto;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get signOut;

  /// No description provided for @verifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get verifyAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get signingIn;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinExhibition.
  ///
  /// In en, this message translates to:
  /// **'Join the exhibition and start voting'**
  String get joinExhibition;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @identifier.
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get identifier;

  /// No description provided for @enterIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username'**
  String get enterIdentifier;

  /// No description provided for @identifierRequired.
  ///
  /// In en, this message translates to:
  /// **'Identifier is required'**
  String get identifierRequired;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating Account...'**
  String get creatingAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToVote.
  ///
  /// In en, this message translates to:
  /// **'Sign in to vote for your favorite projects'**
  String get signInToVote;

  /// No description provided for @yourRole.
  ///
  /// In en, this message translates to:
  /// **'Your Role'**
  String get yourRole;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @professor.
  ///
  /// In en, this message translates to:
  /// **'Professor'**
  String get professor;

  /// No description provided for @visitor.
  ///
  /// In en, this message translates to:
  /// **'Visitor'**
  String get visitor;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @departmentHint.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get departmentHint;

  /// No description provided for @universityIdOptional.
  ///
  /// In en, this message translates to:
  /// **'University ID (optional)'**
  String get universityIdOptional;

  /// No description provided for @universityIdHint.
  ///
  /// In en, this message translates to:
  /// **'2024001234'**
  String get universityIdHint;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (optional)'**
  String get phoneOptional;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+964 xxx xxx xxxx'**
  String get phoneHint;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @tellUsAboutYou.
  ///
  /// In en, this message translates to:
  /// **'Tell Us About You'**
  String get tellUsAboutYou;

  /// No description provided for @personalizeExperience.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your exhibition experience'**
  String get personalizeExperience;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a reset token.'**
  String get resetPasswordDesc;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Token'**
  String get sendResetLink;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset token to\n{email}'**
  String resetLinkSent(String email);

  /// No description provided for @confirmResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get confirmResetTitle;

  /// No description provided for @confirmResetDesc.
  ///
  /// In en, this message translates to:
  /// **'Paste the token from your email and enter a new password.'**
  String get confirmResetDesc;

  /// No description provided for @resetToken.
  ///
  /// In en, this message translates to:
  /// **'Reset Token'**
  String get resetToken;

  /// No description provided for @pasteToken.
  ///
  /// In en, this message translates to:
  /// **'Paste token from email'**
  String get pasteToken;

  /// No description provided for @tokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Token is required'**
  String get tokenRequired;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get confirmPasswordHint;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @resetting.
  ///
  /// In en, this message translates to:
  /// **'Resetting...'**
  String get resetting;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. Please sign in.'**
  String get passwordResetSuccess;

  /// No description provided for @verifyYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Account'**
  String get verifyYourAccount;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to'**
  String get codeSentTo;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @browseByCategory.
  ///
  /// In en, this message translates to:
  /// **'Browse projects by category'**
  String get browseByCategory;

  /// No description provided for @aiMl.
  ///
  /// In en, this message translates to:
  /// **'AI / ML'**
  String get aiMl;

  /// No description provided for @webDev.
  ///
  /// In en, this message translates to:
  /// **'Web Dev'**
  String get webDev;

  /// No description provided for @mobileApps.
  ///
  /// In en, this message translates to:
  /// **'Mobile Apps'**
  String get mobileApps;

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @iot.
  ///
  /// In en, this message translates to:
  /// **'IoT'**
  String get iot;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @projectCount.
  ///
  /// In en, this message translates to:
  /// **'{count} projects'**
  String projectCount(int count);

  /// No description provided for @discoverOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Discover Projects'**
  String get discoverOnboarding;

  /// No description provided for @discoverOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse innovative software projects created by university students.'**
  String get discoverOnboardingDesc;

  /// No description provided for @rateVote.
  ///
  /// In en, this message translates to:
  /// **'Rate & Vote'**
  String get rateVote;

  /// No description provided for @rateVoteDesc.
  ///
  /// In en, this message translates to:
  /// **'Vote for your favorite projects and help choose the winners.'**
  String get rateVoteDesc;

  /// No description provided for @celebrateWinners.
  ///
  /// In en, this message translates to:
  /// **'Celebrate Winners'**
  String get celebrateWinners;

  /// No description provided for @celebrateWinnersDesc.
  ///
  /// In en, this message translates to:
  /// **'See trending projects and celebrate the top-voted creations.'**
  String get celebrateWinnersDesc;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @exhibitions.
  ///
  /// In en, this message translates to:
  /// **'Votera'**
  String get exhibitions;

  /// No description provided for @exploreExhibitions.
  ///
  /// In en, this message translates to:
  /// **'Explore exhibitions & events'**
  String get exploreExhibitions;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// No description provided for @noEventsDesc.
  ///
  /// In en, this message translates to:
  /// **'There are no exhibitions or events available right now. Check back later for updates.'**
  String get noEventsDesc;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @exhibition.
  ///
  /// In en, this message translates to:
  /// **'Exhibition'**
  String get exhibition;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @rankings.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get rankings;

  /// No description provided for @myProject.
  ///
  /// In en, this message translates to:
  /// **'My Project'**
  String get myProject;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Updates about events, votes, and results will appear here.'**
  String get noNotificationsDesc;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @universityIdCard.
  ///
  /// In en, this message translates to:
  /// **'University ID Card'**
  String get universityIdCard;

  /// No description provided for @uploadIdDesc.
  ///
  /// In en, this message translates to:
  /// **'Please upload your university ID document.'**
  String get uploadIdDesc;

  /// No description provided for @requestPending.
  ///
  /// In en, this message translates to:
  /// **'Request submitted — pending review.'**
  String get requestPending;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @submitNewRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit New Request'**
  String get submitNewRequest;

  /// No description provided for @fillIdForm.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details and upload a clear photo of your university ID card.'**
  String get fillIdForm;

  /// No description provided for @nameAsOnId.
  ///
  /// In en, this message translates to:
  /// **'As shown on your ID'**
  String get nameAsOnId;

  /// No description provided for @universityId.
  ///
  /// In en, this message translates to:
  /// **'University ID'**
  String get universityId;

  /// No description provided for @universityIdExample.
  ///
  /// In en, this message translates to:
  /// **'CS2021001'**
  String get universityIdExample;

  /// No description provided for @universityIdRequired.
  ///
  /// In en, this message translates to:
  /// **'University ID is required'**
  String get universityIdRequired;

  /// No description provided for @universityIdTooShort.
  ///
  /// In en, this message translates to:
  /// **'ID must be at least 3 characters'**
  String get universityIdTooShort;

  /// No description provided for @departmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Department is required'**
  String get departmentRequired;

  /// No description provided for @stageYear.
  ///
  /// In en, this message translates to:
  /// **'Stage / Year'**
  String get stageYear;

  /// No description provided for @stageYearExample.
  ///
  /// In en, this message translates to:
  /// **'3rd Year'**
  String get stageYearExample;

  /// No description provided for @stageRequired.
  ///
  /// In en, this message translates to:
  /// **'Stage is required'**
  String get stageRequired;

  /// No description provided for @tapToUploadId.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload ID document'**
  String get tapToUploadId;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String noteLabel(String note);

  /// No description provided for @chooseVerificationMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose Verification Method'**
  String get chooseVerificationMethod;

  /// No description provided for @verificationUnlocks.
  ///
  /// In en, this message translates to:
  /// **'Verifying your account unlocks full access to all features.'**
  String get verificationUnlocks;

  /// No description provided for @institutionalEmail.
  ///
  /// In en, this message translates to:
  /// **'Institutional Email'**
  String get institutionalEmail;

  /// No description provided for @verifyWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify with your university email address.\nYou will receive a 6-digit OTP instantly.'**
  String get verifyWithEmail;

  /// No description provided for @instant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get instant;

  /// No description provided for @uploadIdCard.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo of your university ID card.\nAn admin will review your request.'**
  String get uploadIdCard;

  /// No description provided for @requiresReview.
  ///
  /// In en, this message translates to:
  /// **'Requires Review'**
  String get requiresReview;

  /// No description provided for @enterInstitutionalEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Institutional Email'**
  String get enterInstitutionalEmail;

  /// No description provided for @institutionalEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'We will send a 6-digit verification code to your university email.'**
  String get institutionalEmailDesc;

  /// No description provided for @institutionalEmailHint.
  ///
  /// In en, this message translates to:
  /// **'your.name@university.edu'**
  String get institutionalEmailHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account verified! Participant role granted.'**
  String get accountVerified;

  /// No description provided for @communityFeedback.
  ///
  /// In en, this message translates to:
  /// **'Community Feedback'**
  String get communityFeedback;

  /// No description provided for @aboutProject.
  ///
  /// In en, this message translates to:
  /// **'About this Project'**
  String get aboutProject;

  /// No description provided for @techStack.
  ///
  /// In en, this message translates to:
  /// **'Tech Stack'**
  String get techStack;

  /// No description provided for @projectLinks.
  ///
  /// In en, this message translates to:
  /// **'Project Links'**
  String get projectLinks;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get sourceCode;

  /// No description provided for @liveDemo.
  ///
  /// In en, this message translates to:
  /// **'Live Demo'**
  String get liveDemo;

  /// No description provided for @communityRating.
  ///
  /// In en, this message translates to:
  /// **'Community Rating'**
  String get communityRating;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @ratingCount.
  ///
  /// In en, this message translates to:
  /// **'{totalRatings} rating(s)'**
  String ratingCount(int totalRatings);

  /// No description provided for @rateThisProject.
  ///
  /// In en, this message translates to:
  /// **'Rate this project'**
  String get rateThisProject;

  /// No description provided for @tapStarToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to share your rating'**
  String get tapStarToRate;

  /// No description provided for @writeYourReview.
  ///
  /// In en, this message translates to:
  /// **'Write your review (optional)'**
  String get writeYourReview;

  /// No description provided for @selectStarFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a star rating before submitting.'**
  String get selectStarFirst;

  /// No description provided for @loadMoreComments.
  ///
  /// In en, this message translates to:
  /// **'Load more comments'**
  String get loadMoreComments;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first!'**
  String get noCommentsYet;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @yourVotes.
  ///
  /// In en, this message translates to:
  /// **'Your Votes'**
  String get yourVotes;

  /// No description provided for @votesCast.
  ///
  /// In en, this message translates to:
  /// **'Votes Cast'**
  String get votesCast;

  /// No description provided for @rated.
  ///
  /// In en, this message translates to:
  /// **'Rated'**
  String get rated;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullToRefresh;

  /// No description provided for @vote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get vote;

  /// No description provided for @voted.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get voted;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @voteCount.
  ///
  /// In en, this message translates to:
  /// **'{voteCount} votes'**
  String voteCount(int voteCount);

  /// No description provided for @myTeam.
  ///
  /// In en, this message translates to:
  /// **'My Team'**
  String get myTeam;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully.'**
  String get invitationSent;

  /// No description provided for @leaveTeam.
  ///
  /// In en, this message translates to:
  /// **'Leave Team'**
  String get leaveTeam;

  /// No description provided for @inviteMember.
  ///
  /// In en, this message translates to:
  /// **'Invite Member'**
  String get inviteMember;

  /// No description provided for @enterUserIdToInvite.
  ///
  /// In en, this message translates to:
  /// **'Enter user ID to invite'**
  String get enterUserIdToInvite;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send Invite'**
  String get sendInvite;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this member from your team?'**
  String get removeMemberConfirm;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @noMembersForLeadership.
  ///
  /// In en, this message translates to:
  /// **'No other members to transfer leadership to.'**
  String get noMembersForLeadership;

  /// No description provided for @transferLeadership.
  ///
  /// In en, this message translates to:
  /// **'Transfer Leadership'**
  String get transferLeadership;

  /// No description provided for @selectNewLeader.
  ///
  /// In en, this message translates to:
  /// **'Select the member who will become the new team leader.'**
  String get selectNewLeader;

  /// No description provided for @transferLeadershipFirst.
  ///
  /// In en, this message translates to:
  /// **'Transfer leadership to another member before leaving.'**
  String get transferLeadershipFirst;

  /// No description provided for @leaveAndDelete.
  ///
  /// In en, this message translates to:
  /// **'Leave & Delete Team'**
  String get leaveAndDelete;

  /// No description provided for @leaveAndDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'You are the only member. Leaving will permanently delete \"{name}\". This cannot be undone.'**
  String leaveAndDeleteDesc(String name);

  /// No description provided for @leaveAndDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Leave & Delete'**
  String get leaveAndDeleteButton;

  /// No description provided for @leaveTeamConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave your team? You can join or create another team later.'**
  String get leaveTeamConfirm;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @deleteTeam.
  ///
  /// In en, this message translates to:
  /// **'Delete Team'**
  String get deleteTeam;

  /// No description provided for @deleteTeamDesc.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\" and remove all members. This cannot be undone.'**
  String deleteTeamDesc(String name);

  /// No description provided for @findATeam.
  ///
  /// In en, this message translates to:
  /// **'Find a Team'**
  String get findATeam;

  /// No description provided for @findATeamDesc.
  ///
  /// In en, this message translates to:
  /// **'Search by team name to discover and join existing teams.'**
  String get findATeamDesc;

  /// No description provided for @noTeamsFound.
  ///
  /// In en, this message translates to:
  /// **'No teams found'**
  String get noTeamsFound;

  /// No description provided for @noTeamsMatchedQuery.
  ///
  /// In en, this message translates to:
  /// **'No teams matched \"{query}\". Try a different name.'**
  String noTeamsMatchedQuery(String query);

  /// No description provided for @leader.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get leader;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} member(s)'**
  String memberCount(int count);

  /// No description provided for @membersWithCount.
  ///
  /// In en, this message translates to:
  /// **'Members ({count})'**
  String membersWithCount(int count);

  /// No description provided for @pendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvitations;

  /// No description provided for @teamSettings.
  ///
  /// In en, this message translates to:
  /// **'Team Settings'**
  String get teamSettings;

  /// No description provided for @editTeamInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Team Info'**
  String get editTeamInfo;

  /// No description provided for @changeTeamNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Change team name or description'**
  String get changeTeamNameDesc;

  /// No description provided for @assignNewLeader.
  ///
  /// In en, this message translates to:
  /// **'Assign a new team leader'**
  String get assignNewLeader;

  /// No description provided for @permanentlyDisband.
  ///
  /// In en, this message translates to:
  /// **'Permanently disband this team'**
  String get permanentlyDisband;

  /// No description provided for @leaveTeamOnlyMember.
  ///
  /// In en, this message translates to:
  /// **'If you are the only member, the team will be deleted'**
  String get leaveTeamOnlyMember;

  /// No description provided for @notInTeamYet.
  ///
  /// In en, this message translates to:
  /// **'You are not in a team yet'**
  String get notInTeamYet;

  /// No description provided for @createOrJoinTeam.
  ///
  /// In en, this message translates to:
  /// **'Create your own team or browse existing ones to join.'**
  String get createOrJoinTeam;

  /// No description provided for @createATeam.
  ///
  /// In en, this message translates to:
  /// **'Create a Team'**
  String get createATeam;

  /// No description provided for @browseTeams.
  ///
  /// In en, this message translates to:
  /// **'Browse Teams'**
  String get browseTeams;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @searchTeamsByName.
  ///
  /// In en, this message translates to:
  /// **'Search teams by name...'**
  String get searchTeamsByName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @voting.
  ///
  /// In en, this message translates to:
  /// **'Voting'**
  String get voting;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @submissionsOpen.
  ///
  /// In en, this message translates to:
  /// **'Submissions open'**
  String get submissionsOpen;

  /// No description provided for @voteNow.
  ///
  /// In en, this message translates to:
  /// **'Vote now'**
  String get voteNow;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// No description provided for @teamSizeRange.
  ///
  /// In en, this message translates to:
  /// **'{minSize}-{maxSize} members'**
  String teamSizeRange(int minSize, int maxSize);

  /// No description provided for @teamSizeMin.
  ///
  /// In en, this message translates to:
  /// **'{minSize}+ members'**
  String teamSizeMin(int minSize);

  /// No description provided for @teamSizeMax.
  ///
  /// In en, this message translates to:
  /// **'Up to {maxSize}'**
  String teamSizeMax(int maxSize);

  /// No description provided for @maxVotes.
  ///
  /// In en, this message translates to:
  /// **'{maxVotes} votes'**
  String maxVotes(int maxVotes);

  /// No description provided for @teamInvitation.
  ///
  /// In en, this message translates to:
  /// **'Team Invitation'**
  String get teamInvitation;

  /// No description provided for @teamLabel.
  ///
  /// In en, this message translates to:
  /// **'Team: {teamId}'**
  String teamLabel(String teamId);

  /// No description provided for @invitedBy.
  ///
  /// In en, this message translates to:
  /// **'Invited by: {inviter}'**
  String invitedBy(String inviter);

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @userFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userFallback;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @rankingsCommunityTab.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get rankingsCommunityTab;

  /// No description provided for @rankingsSupervisorTab.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get rankingsSupervisorTab;

  /// No description provided for @noRankingsYet.
  ///
  /// In en, this message translates to:
  /// **'No rankings yet'**
  String get noRankingsYet;

  /// No description provided for @rankingsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Rankings will appear once voting begins.'**
  String get rankingsWillAppear;

  /// No description provided for @rankingsLabel.
  ///
  /// In en, this message translates to:
  /// **'RANKINGS'**
  String get rankingsLabel;

  /// No description provided for @votesLabel.
  ///
  /// In en, this message translates to:
  /// **'VOTES'**
  String get votesLabel;

  /// No description provided for @votesWithCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Votes'**
  String votesWithCount(int count);

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @noCategoriesDesc.
  ///
  /// In en, this message translates to:
  /// **'There are no categories available for this event.'**
  String get noCategoriesDesc;

  /// No description provided for @youSuffix.
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get youSuffix;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedDate(String date);

  /// No description provided for @removeMemberTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMemberTooltip;

  /// No description provided for @invitationSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully.'**
  String get invitationSentSuccess;

  /// No description provided for @editTeamInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Team Info'**
  String get editTeamInfoTitle;

  /// No description provided for @transferLeadershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Leadership'**
  String get transferLeadershipTitle;

  /// No description provided for @deleteTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Team'**
  String get deleteTeamTitle;

  /// No description provided for @leaveTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Team'**
  String get leaveTeamTitle;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteTeamImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Team Photo'**
  String get deleteTeamImage;

  /// No description provided for @deleteTeamImageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the team photo?'**
  String get deleteTeamImageConfirm;

  /// No description provided for @needATeamFirst.
  ///
  /// In en, this message translates to:
  /// **'You need a team first'**
  String get needATeamFirst;

  /// No description provided for @needATeamDesc.
  ///
  /// In en, this message translates to:
  /// **'Create or join a team before you can submit a project to this event.'**
  String get needATeamDesc;

  /// No description provided for @selectTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Team'**
  String get selectTeamTitle;

  /// No description provided for @selectTeamDesc.
  ///
  /// In en, this message translates to:
  /// **'You are a member of multiple teams. Choose which team will submit this project.'**
  String get selectTeamDesc;

  /// No description provided for @submittingAsTeam.
  ///
  /// In en, this message translates to:
  /// **'Submitting as'**
  String get submittingAsTeam;

  /// No description provided for @submitYourProject.
  ///
  /// In en, this message translates to:
  /// **'Submit Your Project'**
  String get submitYourProject;

  /// No description provided for @submitYourProjectDesc.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to register your project for this event.'**
  String get submitYourProjectDesc;

  /// No description provided for @projectTitle.
  ///
  /// In en, this message translates to:
  /// **'Project Title *'**
  String get projectTitle;

  /// No description provided for @projectTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Smart Irrigation System'**
  String get projectTitleHint;

  /// No description provided for @projectTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get projectTitleRequired;

  /// No description provided for @projectTitleTooShort.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 3 characters'**
  String get projectTitleTooShort;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What does your project do?'**
  String get descriptionHint;

  /// No description provided for @techStackLabel.
  ///
  /// In en, this message translates to:
  /// **'Tech Stack'**
  String get techStackLabel;

  /// No description provided for @techStackHint.
  ///
  /// In en, this message translates to:
  /// **'Flutter, Firebase, Python'**
  String get techStackHint;

  /// No description provided for @repositoryUrl.
  ///
  /// In en, this message translates to:
  /// **'Repository URL'**
  String get repositoryUrl;

  /// No description provided for @repositoryUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://github.com/...'**
  String get repositoryUrlHint;

  /// No description provided for @demoUrl.
  ///
  /// In en, this message translates to:
  /// **'Demo URL'**
  String get demoUrl;

  /// No description provided for @demoUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get demoUrlHint;

  /// No description provided for @submitProject.
  ///
  /// In en, this message translates to:
  /// **'Submit Project'**
  String get submitProject;

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit Project'**
  String get editProject;

  /// No description provided for @editProjectDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your project details below.'**
  String get editProjectDesc;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @viewProject.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewProject;

  /// No description provided for @noLinksAdded.
  ///
  /// In en, this message translates to:
  /// **'No links added yet'**
  String get noLinksAdded;

  /// No description provided for @repositoryChip.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get repositoryChip;

  /// No description provided for @demoChip.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demoChip;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdLabel;

  /// No description provided for @draftStatusBanner.
  ///
  /// In en, this message translates to:
  /// **'Draft — not yet submitted for review'**
  String get draftStatusBanner;

  /// No description provided for @submittedStatusBanner.
  ///
  /// In en, this message translates to:
  /// **'Submitted — awaiting organizer review'**
  String get submittedStatusBanner;

  /// No description provided for @acceptedStatusBanner.
  ///
  /// In en, this message translates to:
  /// **'Accepted — your project was approved'**
  String get acceptedStatusBanner;

  /// No description provided for @rejectedStatusBanner.
  ///
  /// In en, this message translates to:
  /// **'Rejected — check organizer feedback'**
  String get rejectedStatusBanner;

  /// No description provided for @editProjectButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Project'**
  String get editProjectButton;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get submitForReview;

  /// No description provided for @cancelSubmission.
  ///
  /// In en, this message translates to:
  /// **'Cancel Submission'**
  String get cancelSubmission;

  /// No description provided for @submitForReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review?'**
  String get submitForReviewTitle;

  /// No description provided for @submitForReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Your project will be sent to the organizers for review. You can cancel the submission at any time before it is reviewed.'**
  String get submitForReviewDesc;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancelSubmissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Submission?'**
  String get cancelSubmissionTitle;

  /// No description provided for @cancelSubmissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Your project will be moved back to draft. You can re-submit at any time.'**
  String get cancelSubmissionDesc;

  /// No description provided for @keepSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Keep submitted'**
  String get keepSubmitted;

  /// No description provided for @cancelSubmissionButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel submission'**
  String get cancelSubmissionButton;

  /// No description provided for @editTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Team'**
  String get editTeamTitle;

  /// No description provided for @editTeamDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your team details below.'**
  String get editTeamDesc;

  /// No description provided for @createTeamDesc.
  ///
  /// In en, this message translates to:
  /// **'Give your team a name and an optional description.'**
  String get createTeamDesc;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team Name'**
  String get teamName;

  /// No description provided for @teamHandle.
  ///
  /// In en, this message translates to:
  /// **'Team Handle'**
  String get teamHandle;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Member Name'**
  String get memberName;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @teamNameHint.
  ///
  /// In en, this message translates to:
  /// **'The Innovators'**
  String get teamNameHint;

  /// No description provided for @teamNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Team name is required'**
  String get teamNameRequired;

  /// No description provided for @teamNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get teamNameTooShort;

  /// No description provided for @teamDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get teamDescriptionOptional;

  /// No description provided for @teamDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What is your team about?'**
  String get teamDescriptionHint;

  /// No description provided for @createTeamButton.
  ///
  /// In en, this message translates to:
  /// **'Create Team'**
  String get createTeamButton;

  /// No description provided for @noProjectsYet.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get noProjectsYet;

  /// No description provided for @noProjectsDesc.
  ///
  /// In en, this message translates to:
  /// **'There are no projects submitted for this event yet.'**
  String get noProjectsDesc;

  /// No description provided for @noProjectsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No projects in this category'**
  String get noProjectsInCategory;

  /// No description provided for @noProjectsInCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'No projects have been tagged with this category yet.'**
  String get noProjectsInCategoryDesc;

  /// No description provided for @noProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No projects found'**
  String get noProjectsFound;

  /// No description provided for @noProjectsFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'No projects matched your search. Try a different title.'**
  String get noProjectsFoundDesc;

  /// No description provided for @searchProjectsTeams.
  ///
  /// In en, this message translates to:
  /// **'Search projects or teams...'**
  String get searchProjectsTeams;

  /// No description provided for @trendingNow.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get trendingNow;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @heyThere.
  ///
  /// In en, this message translates to:
  /// **'Hey there!'**
  String get heyThere;

  /// No description provided for @springHackathon.
  ///
  /// In en, this message translates to:
  /// **'Spring Hackathon'**
  String get springHackathon;

  /// No description provided for @thePrefix.
  ///
  /// In en, this message translates to:
  /// **'The '**
  String get thePrefix;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @waitingForTelegram.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Telegram...'**
  String get waitingForTelegram;

  /// No description provided for @continueWithTelegram.
  ///
  /// In en, this message translates to:
  /// **'Continue with Telegram'**
  String get continueWithTelegram;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who Are You?'**
  String get whoAreYou;

  /// No description provided for @chooseRoleToVerify.
  ///
  /// In en, this message translates to:
  /// **'Choose your role to verify your university account.'**
  String get chooseRoleToVerify;

  /// No description provided for @iAmStudent.
  ///
  /// In en, this message translates to:
  /// **'I am a Student'**
  String get iAmStudent;

  /// No description provided for @studentEmailExample.
  ///
  /// In en, this message translates to:
  /// **'5920220096@student.uokufa.edu.iq'**
  String get studentEmailExample;

  /// No description provided for @iAmTeacher.
  ///
  /// In en, this message translates to:
  /// **'I am a Professor / Supervisor'**
  String get iAmTeacher;

  /// No description provided for @teacherEmailExample.
  ///
  /// In en, this message translates to:
  /// **'ahmedh.almajidy@uokufa.edu.iq'**
  String get teacherEmailExample;

  /// No description provided for @studentEmailDomainError.
  ///
  /// In en, this message translates to:
  /// **'Must be a student email (@student.uokufa.edu.iq)'**
  String get studentEmailDomainError;

  /// No description provided for @teacherEmailDomainError.
  ///
  /// In en, this message translates to:
  /// **'Must be a supervisor email (@uokufa.edu.iq)'**
  String get teacherEmailDomainError;

  /// No description provided for @teacherEmailNotStudent.
  ///
  /// In en, this message translates to:
  /// **'Professor email cannot be a student email'**
  String get teacherEmailNotStudent;

  /// No description provided for @supervisorEmail.
  ///
  /// In en, this message translates to:
  /// **'Supervisor Email'**
  String get supervisorEmail;

  /// No description provided for @enterSupervisorEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Supervisor Email'**
  String get enterSupervisorEmail;

  /// No description provided for @supervisorEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'We will send a 6-digit verification code to your supervisor email.'**
  String get supervisorEmailDesc;

  /// No description provided for @supervisorEmailHint.
  ///
  /// In en, this message translates to:
  /// **'your.name@uokufa.edu.iq'**
  String get supervisorEmailHint;

  /// No description provided for @supervisorAccountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account verified! Supervisor role granted.'**
  String get supervisorAccountVerified;

  /// No description provided for @studentVerified.
  ///
  /// In en, this message translates to:
  /// **'Student Verified'**
  String get studentVerified;

  /// No description provided for @teacherVerified.
  ///
  /// In en, this message translates to:
  /// **'Professor Verified'**
  String get teacherVerified;

  /// No description provided for @telegramVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified via Telegram'**
  String get telegramVerified;

  /// No description provided for @requestToJoin.
  ///
  /// In en, this message translates to:
  /// **'Request to Join'**
  String get requestToJoin;

  /// No description provided for @joinRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Your request to join has been sent.'**
  String get joinRequestSent;

  /// No description provided for @joinRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get joinRequestMessage;

  /// No description provided for @joinRequestMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Introduce yourself or explain why you want to join...'**
  String get joinRequestMessageHint;

  /// No description provided for @joinRequests.
  ///
  /// In en, this message translates to:
  /// **'Join Requests'**
  String get joinRequests;

  /// No description provided for @noJoinRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending join requests.'**
  String get noJoinRequests;

  /// No description provided for @approveRequest.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveRequest;

  /// No description provided for @declineRequest.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineRequest;

  /// No description provided for @shareProjectSubject.
  ///
  /// In en, this message translates to:
  /// **'Check out this project on Votera!'**
  String get shareProjectSubject;

  /// No description provided for @shareProjectMessage.
  ///
  /// In en, this message translates to:
  /// **'I found an interesting project on Votera. Tap the link to view it:'**
  String get shareProjectMessage;

  /// No description provided for @votingPhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Voting is Live'**
  String get votingPhaseTitle;

  /// No description provided for @votingPhaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Project submissions are closed. The community is now voting.'**
  String get votingPhaseDesc;

  /// No description provided for @eventClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Has Ended'**
  String get eventClosedTitle;

  /// No description provided for @eventClosedDesc.
  ///
  /// In en, this message translates to:
  /// **'This event is closed and no longer accepting project submissions.'**
  String get eventClosedDesc;

  /// No description provided for @eventNotStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Not Started Yet'**
  String get eventNotStartedTitle;

  /// No description provided for @eventNotStartedDesc.
  ///
  /// In en, this message translates to:
  /// **'This event hasn\'t opened for submissions yet. Check back soon.'**
  String get eventNotStartedDesc;

  /// No description provided for @eventArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Archived'**
  String get eventArchivedTitle;

  /// No description provided for @eventArchivedDesc.
  ///
  /// In en, this message translates to:
  /// **'This event has been archived and is no longer active.'**
  String get eventArchivedDesc;

  /// No description provided for @projectImages.
  ///
  /// In en, this message translates to:
  /// **'Project Images'**
  String get projectImages;

  /// No description provided for @coverImage.
  ///
  /// In en, this message translates to:
  /// **'Cover Image'**
  String get coverImage;

  /// No description provided for @addCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Add Cover Image'**
  String get addCoverImage;

  /// No description provided for @changeCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeCoverImage;

  /// No description provided for @extraImages.
  ///
  /// In en, this message translates to:
  /// **'Extra Images'**
  String get extraImages;

  /// No description provided for @addExtraImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addExtraImage;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeImage;

  /// No description provided for @confirmRemoveCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Cover Image?'**
  String get confirmRemoveCoverTitle;

  /// No description provided for @confirmRemoveCoverDesc.
  ///
  /// In en, this message translates to:
  /// **'The cover image will be permanently deleted.'**
  String get confirmRemoveCoverDesc;

  /// No description provided for @confirmRemoveImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Image?'**
  String get confirmRemoveImageTitle;

  /// No description provided for @confirmRemoveImageDesc.
  ///
  /// In en, this message translates to:
  /// **'This image will be permanently deleted.'**
  String get confirmRemoveImageDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

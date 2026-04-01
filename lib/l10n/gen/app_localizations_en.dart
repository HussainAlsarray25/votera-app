// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get all => 'All';

  @override
  String get allProjects => 'All Projects';

  @override
  String get appTitle => 'Votera';

  @override
  String get appTagline =>
      'Discover, vote, and celebrate\ninnovative projects.';

  @override
  String get appMotto => 'Discover. Vote. Celebrate.';

  @override
  String get home => 'Home';

  @override
  String get teams => 'Teams';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get signOut => 'Log Out';

  @override
  String get verifyAccount => 'Verify Account';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signingIn => 'Signing In...';

  @override
  String get signIn => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinExhibition => 'Join the exhibition and start voting';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get identifier => 'Identifier';

  @override
  String get enterIdentifier => 'Enter your email or username';

  @override
  String get identifierRequired => 'Identifier is required';

  @override
  String get createPassword => 'Create a password';

  @override
  String get creatingAccount => 'Creating Account...';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToVote => 'Sign in to vote for your favorite projects';

  @override
  String get yourRole => 'Your Role';

  @override
  String get student => 'Student';

  @override
  String get professor => 'Professor';

  @override
  String get visitor => 'Visitor';

  @override
  String get department => 'Department';

  @override
  String get departmentHint => 'Computer Science';

  @override
  String get universityIdOptional => 'University ID (optional)';

  @override
  String get universityIdHint => '2024001234';

  @override
  String get phoneOptional => 'Phone Number (optional)';

  @override
  String get phoneHint => '+964 xxx xxx xxxx';

  @override
  String get continueButton => 'Continue';

  @override
  String get tellUsAboutYou => 'Tell Us About You';

  @override
  String get personalizeExperience =>
      'Help us personalize your exhibition experience';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get resetPassword => 'Reset Your Password';

  @override
  String get resetPasswordDesc =>
      'Enter your email and we will send you a reset token.';

  @override
  String get sending => 'Sending...';

  @override
  String get sendResetLink => 'Send Reset Token';

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String resetLinkSent(String email) {
    return 'We sent a password reset token to\n$email';
  }

  @override
  String get confirmResetTitle => 'Set New Password';

  @override
  String get confirmResetDesc =>
      'Paste the token from your email and enter a new password.';

  @override
  String get resetToken => 'Reset Token';

  @override
  String get pasteToken => 'Paste token from email';

  @override
  String get tokenRequired => 'Token is required';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get newPasswordRequired => 'New password is required';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get resetting => 'Resetting...';

  @override
  String get setNewPassword => 'Set New Password';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully. Please sign in.';

  @override
  String get verifyYourAccount => 'Verify Your Account';

  @override
  String get enterVerificationCode => 'Enter Verification Code';

  @override
  String get codeSentTo => 'We sent a 6-digit code to';

  @override
  String get verifying => 'Verifying...';

  @override
  String get verify => 'Verify';

  @override
  String get categories => 'Categories';

  @override
  String get browseByCategory => 'Browse projects by category';

  @override
  String get aiMl => 'AI / ML';

  @override
  String get webDev => 'Web Dev';

  @override
  String get mobileApps => 'Mobile Apps';

  @override
  String get game => 'Game';

  @override
  String get iot => 'IoT';

  @override
  String get data => 'Data';

  @override
  String projectCount(int count) {
    return '$count projects';
  }

  @override
  String get discoverOnboarding => 'Discover Projects';

  @override
  String get discoverOnboardingDesc =>
      'Browse innovative software projects created by university students.';

  @override
  String get rateVote => 'Rate & Vote';

  @override
  String get rateVoteDesc =>
      'Vote for your favorite projects and help choose the winners.';

  @override
  String get celebrateWinners => 'Celebrate Winners';

  @override
  String get celebrateWinnersDesc =>
      'See trending projects and celebrate the top-voted creations.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get exhibitions => 'Votera';

  @override
  String get exploreExhibitions => 'Explore exhibitions & events';

  @override
  String get noEventsYet => 'No events yet';

  @override
  String get noEventsDesc =>
      'There are no exhibitions or events available right now. Check back later for updates.';

  @override
  String get retry => 'Retry';

  @override
  String get exhibition => 'Exhibition';

  @override
  String get projects => 'Projects';

  @override
  String get rankings => 'Rankings';

  @override
  String get myProject => 'My Project';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get noNotificationsDesc =>
      'Updates about events, votes, and results will appear here.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get earlier => 'Earlier';

  @override
  String get universityIdCard => 'University ID Card';

  @override
  String get uploadIdDesc => 'Please upload your university ID document.';

  @override
  String get requestPending => 'Request submitted — pending review.';

  @override
  String get myRequests => 'My Requests';

  @override
  String get submitNewRequest => 'Submit New Request';

  @override
  String get fillIdForm =>
      'Fill in your details and upload a clear photo of your university ID card.';

  @override
  String get nameAsOnId => 'As shown on your ID';

  @override
  String get universityId => 'University ID';

  @override
  String get universityIdExample => 'CS2021001';

  @override
  String get universityIdRequired => 'University ID is required';

  @override
  String get universityIdTooShort => 'ID must be at least 3 characters';

  @override
  String get departmentRequired => 'Department is required';

  @override
  String get stageYear => 'Stage / Year';

  @override
  String get stageYearExample => '3rd Year';

  @override
  String get stageRequired => 'Stage is required';

  @override
  String get tapToUploadId => 'Tap to upload ID document';

  @override
  String get submitting => 'Submitting...';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get pending => 'Pending';

  @override
  String noteLabel(String note) {
    return 'Note: $note';
  }

  @override
  String get chooseVerificationMethod => 'Choose Verification Method';

  @override
  String get verificationUnlocks =>
      'Verifying your account unlocks full access to all features.';

  @override
  String get institutionalEmail => 'Institutional Email';

  @override
  String get verifyWithEmail =>
      'Verify with your university email address.\nYou will receive a 6-digit OTP instantly.';

  @override
  String get instant => 'Instant';

  @override
  String get uploadIdCard =>
      'Upload a photo of your university ID card.\nAn admin will review your request.';

  @override
  String get requiresReview => 'Requires Review';

  @override
  String get enterInstitutionalEmail => 'Enter Your Institutional Email';

  @override
  String get institutionalEmailDesc =>
      'We will send a 6-digit verification code to your university email.';

  @override
  String get institutionalEmailHint => 'your.name@university.edu';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get accountVerified => 'Account verified! Participant role granted.';

  @override
  String get communityFeedback => 'Community Feedback';

  @override
  String get aboutProject => 'About this Project';

  @override
  String get techStack => 'Tech Stack';

  @override
  String get projectLinks => 'Project Links';

  @override
  String get sourceCode => 'Source Code';

  @override
  String get liveDemo => 'Live Demo';

  @override
  String get communityRating => 'Community Rating';

  @override
  String get loading => 'Loading...';

  @override
  String ratingCount(int totalRatings) {
    return '$totalRatings rating(s)';
  }

  @override
  String get rateThisProject => 'Rate this project';

  @override
  String get tapStarToRate => 'Tap a star to share your rating';

  @override
  String get writeYourReview => 'Write your review (optional)';

  @override
  String get selectStarFirst =>
      'Please select a star rating before submitting.';

  @override
  String get loadMoreComments => 'Load more comments';

  @override
  String get comments => 'Comments';

  @override
  String get addComment => 'Add a comment...';

  @override
  String get noCommentsYet => 'No comments yet. Be the first!';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusDraft => 'Draft';

  @override
  String get yourVotes => 'Your Votes';

  @override
  String get votesCast => 'Votes Cast';

  @override
  String get rated => 'Rated';

  @override
  String get pullToRefresh => 'Pull down to refresh';

  @override
  String get vote => 'Vote';

  @override
  String get voted => 'Voted';

  @override
  String get trending => 'Trending';

  @override
  String get winner => 'Winner';

  @override
  String voteCount(int voteCount) {
    return '$voteCount votes';
  }

  @override
  String get myTeam => 'My Team';

  @override
  String get browse => 'Browse';

  @override
  String get invitationSent => 'Invitation sent successfully.';

  @override
  String get leaveTeam => 'Leave Team';

  @override
  String get inviteMember => 'Invite Member';

  @override
  String get enterUserIdToInvite => 'Enter user ID to invite';

  @override
  String get sendInvite => 'Send Invite';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get removeMemberConfirm =>
      'Are you sure you want to remove this member from your team?';

  @override
  String get remove => 'Remove';

  @override
  String get noMembersForLeadership =>
      'No other members to transfer leadership to.';

  @override
  String get transferLeadership => 'Transfer Leadership';

  @override
  String get selectNewLeader =>
      'Select the member who will become the new team leader.';

  @override
  String get transferLeadershipFirst =>
      'Transfer leadership to another member before leaving.';

  @override
  String get leaveAndDelete => 'Leave & Delete Team';

  @override
  String leaveAndDeleteDesc(String name) {
    return 'You are the only member. Leaving will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get leaveAndDeleteButton => 'Leave & Delete';

  @override
  String get leaveTeamConfirm =>
      'Are you sure you want to leave your team? You can join or create another team later.';

  @override
  String get leave => 'Leave';

  @override
  String get deleteTeam => 'Delete Team';

  @override
  String deleteTeamDesc(String name) {
    return 'This will permanently delete \"$name\" and remove all members. This cannot be undone.';
  }

  @override
  String get findATeam => 'Find a Team';

  @override
  String get findATeamDesc =>
      'Search by team name to discover and join existing teams.';

  @override
  String get noTeamsFound => 'No teams found';

  @override
  String noTeamsMatchedQuery(String query) {
    return 'No teams matched \"$query\". Try a different name.';
  }

  @override
  String get leader => 'Leader';

  @override
  String memberCount(int count) {
    return '$count member(s)';
  }

  @override
  String membersWithCount(int count) {
    return 'Members ($count)';
  }

  @override
  String get pendingInvitations => 'Pending Invitations';

  @override
  String get teamSettings => 'Team Settings';

  @override
  String get editTeamInfo => 'Edit Team Info';

  @override
  String get changeTeamNameDesc => 'Change team name or description';

  @override
  String get assignNewLeader => 'Assign a new team leader';

  @override
  String get permanentlyDisband => 'Permanently disband this team';

  @override
  String get leaveTeamOnlyMember =>
      'If you are the only member, the team will be deleted';

  @override
  String get notInTeamYet => 'You are not in a team yet';

  @override
  String get createOrJoinTeam =>
      'Create your own team or browse existing ones to join.';

  @override
  String get createATeam => 'Create a Team';

  @override
  String get browseTeams => 'Browse Teams';

  @override
  String get invite => 'Invite';

  @override
  String get searchTeamsByName => 'Search teams by name...';

  @override
  String get cancel => 'Cancel';

  @override
  String get about => 'About';

  @override
  String get tryAgain => 'Try again';

  @override
  String get open => 'Open';

  @override
  String get voting => 'Voting';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get closed => 'Closed';

  @override
  String get archived => 'Archived';

  @override
  String get submissionsOpen => 'Submissions open';

  @override
  String get voteNow => 'Vote now';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get ended => 'Ended';

  @override
  String teamSizeRange(int minSize, int maxSize) {
    return '$minSize-$maxSize members';
  }

  @override
  String teamSizeMin(int minSize) {
    return '$minSize+ members';
  }

  @override
  String teamSizeMax(int maxSize) {
    return 'Up to $maxSize';
  }

  @override
  String maxVotes(int maxVotes) {
    return '$maxVotes votes';
  }

  @override
  String get teamInvitation => 'Team Invitation';

  @override
  String teamLabel(String teamId) {
    return 'Team: $teamId';
  }

  @override
  String invitedBy(String inviter) {
    return 'Invited by: $inviter';
  }

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get userFallback => 'User';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get rankingsCommunityTab => 'Community';

  @override
  String get rankingsSupervisorTab => 'Supervisor';

  @override
  String get noRankingsYet => 'No rankings yet';

  @override
  String get rankingsWillAppear => 'Rankings will appear once voting begins.';

  @override
  String get rankingsLabel => 'RANKINGS';

  @override
  String get votesLabel => 'VOTES';

  @override
  String votesWithCount(int count) {
    return '$count Votes';
  }

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get noCategoriesDesc =>
      'There are no categories available for this event.';

  @override
  String get youSuffix => '(you)';

  @override
  String joinedDate(String date) {
    return 'Joined $date';
  }

  @override
  String get removeMemberTooltip => 'Remove member';

  @override
  String get invitationSentSuccess => 'Invitation sent successfully.';

  @override
  String get editTeamInfoTitle => 'Edit Team Info';

  @override
  String get transferLeadershipTitle => 'Transfer Leadership';

  @override
  String get deleteTeamTitle => 'Delete Team';

  @override
  String get leaveTeamTitle => 'Leave Team';

  @override
  String get delete => 'Delete';

  @override
  String get deleteTeamImage => 'Remove Team Photo';

  @override
  String get deleteTeamImageConfirm =>
      'Are you sure you want to remove the team photo?';

  @override
  String get needATeamFirst => 'You need a team first';

  @override
  String get needATeamDesc =>
      'Create or join a team before you can submit a project to this event.';

  @override
  String get selectTeamTitle => 'Select a Team';

  @override
  String get selectTeamDesc =>
      'You are a member of multiple teams. Choose which team will submit this project.';

  @override
  String get changeTeam => 'Change';

  @override
  String get submittingAsTeam => 'Submitting as';

  @override
  String get submitYourProject => 'Submit Your Project';

  @override
  String get submitYourProjectDesc =>
      'Fill in the details below to register your project for this event.';

  @override
  String get projectTitle => 'Project Title *';

  @override
  String get projectTitleHint => 'Smart Irrigation System';

  @override
  String get projectTitleRequired => 'Title is required';

  @override
  String get projectTitleTooShort => 'Title must be at least 3 characters';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'What does your project do?';

  @override
  String get techStackLabel => 'Tech Stack';

  @override
  String get techStackHint => 'Flutter, Firebase, Python';

  @override
  String get repositoryUrl => 'Repository URL';

  @override
  String get repositoryUrlHint => 'https://github.com/...';

  @override
  String get demoUrl => 'Demo URL';

  @override
  String get demoUrlHint => 'https://...';

  @override
  String get submitProject => 'Submit Project';

  @override
  String get editProject => 'Edit Project';

  @override
  String get editProjectDesc => 'Update your project details below.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get viewProject => 'View';

  @override
  String get noLinksAdded => 'No links added yet';

  @override
  String get repositoryChip => 'Repository';

  @override
  String get demoChip => 'Demo';

  @override
  String get createdLabel => 'Created';

  @override
  String get draftStatusBanner => 'Draft — not yet submitted for review';

  @override
  String get submittedStatusBanner => 'Submitted — awaiting organizer review';

  @override
  String get acceptedStatusBanner => 'Accepted — your project was approved';

  @override
  String get rejectedStatusBanner => 'Rejected — check organizer feedback';

  @override
  String get editProjectButton => 'Edit Project';

  @override
  String get submitForReview => 'Submit for Review';

  @override
  String get cancelSubmission => 'Cancel Submission';

  @override
  String get submitForReviewTitle => 'Submit for Review?';

  @override
  String get submitForReviewDesc =>
      'Your project will be sent to the organizers for review. You can cancel the submission at any time before it is reviewed.';

  @override
  String get notYet => 'Not yet';

  @override
  String get submit => 'Submit';

  @override
  String get cancelSubmissionTitle => 'Cancel Submission?';

  @override
  String get cancelSubmissionDesc =>
      'Your project will be moved back to draft. You can re-submit at any time.';

  @override
  String get keepSubmitted => 'Keep submitted';

  @override
  String get cancelSubmissionButton => 'Cancel submission';

  @override
  String get editTeamTitle => 'Edit Team';

  @override
  String get editTeamDesc => 'Update your team details below.';

  @override
  String get createTeamDesc =>
      'Give your team a name and an optional description.';

  @override
  String get teamName => 'Team Name';

  @override
  String get teamHandle => 'Team Handle';

  @override
  String get memberName => 'Member Name';

  @override
  String get userId => 'User ID';

  @override
  String get teamNameHint => 'The Innovators';

  @override
  String get teamNameRequired => 'Team name is required';

  @override
  String get teamNameTooShort => 'Name must be at least 3 characters';

  @override
  String get teamDescriptionOptional => 'Description (optional)';

  @override
  String get teamDescriptionHint => 'What is your team about?';

  @override
  String get createTeamButton => 'Create Team';

  @override
  String get noProjectsYet => 'No projects yet';

  @override
  String get noProjectsDesc =>
      'There are no projects submitted for this event yet.';

  @override
  String get noProjectsInCategory => 'No projects in this category';

  @override
  String get noProjectsInCategoryDesc =>
      'No projects have been tagged with this category yet.';

  @override
  String get noProjectsFound => 'No projects found';

  @override
  String get noProjectsFoundDesc =>
      'No projects matched your search. Try a different title.';

  @override
  String get searchProjectsTeams => 'Search projects or teams...';

  @override
  String get trendingNow => 'Trending Now';

  @override
  String get seeAll => 'See all';

  @override
  String get heyThere => 'Hey there!';

  @override
  String get springHackathon => 'Spring Hackathon';

  @override
  String get thePrefix => 'The ';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get waitingForTelegram => 'Waiting for Telegram...';

  @override
  String get continueWithTelegram => 'Continue with Telegram';

  @override
  String get settings => 'Settings';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get createdAt => 'Created';

  @override
  String get whoAreYou => 'Who Are You?';

  @override
  String get chooseRoleToVerify =>
      'Choose your role to verify your university account.';

  @override
  String get iAmStudent => 'I am a Student';

  @override
  String get studentEmailExample => '5920220096@student.uokufa.edu.iq';

  @override
  String get iAmTeacher => 'I am a Professor / Supervisor';

  @override
  String get teacherEmailExample => 'ahmedh.almajidy@uokufa.edu.iq';

  @override
  String get studentEmailDomainError =>
      'Must be a student email (@student.uokufa.edu.iq)';

  @override
  String get teacherEmailDomainError =>
      'Must be a supervisor email (@uokufa.edu.iq)';

  @override
  String get teacherEmailNotStudent =>
      'Professor email cannot be a student email';

  @override
  String get supervisorEmail => 'Supervisor Email';

  @override
  String get enterSupervisorEmail => 'Enter Your Supervisor Email';

  @override
  String get supervisorEmailDesc =>
      'We will send a 6-digit verification code to your supervisor email.';

  @override
  String get supervisorEmailHint => 'your.name@uokufa.edu.iq';

  @override
  String get supervisorAccountVerified =>
      'Account verified! Supervisor role granted.';

  @override
  String get studentVerified => 'Student Verified';

  @override
  String get teacherVerified => 'Professor Verified';

  @override
  String get telegramVerified => 'Verified via Telegram';

  @override
  String get requestToJoin => 'Request to Join';

  @override
  String get joinRequestSent => 'Your request to join has been sent.';

  @override
  String get joinRequestMessage => 'Message (optional)';

  @override
  String get joinRequestMessageHint =>
      'Introduce yourself or explain why you want to join...';

  @override
  String get joinRequests => 'Join Requests';

  @override
  String get noJoinRequests => 'No pending join requests.';

  @override
  String get approveRequest => 'Approve';

  @override
  String get declineRequest => 'Decline';

  @override
  String get shareProjectSubject => 'Check out this project on Votera!';

  @override
  String get shareProjectMessage =>
      'I found an interesting project on Votera. Tap the link to view it:';

  @override
  String get votingPhaseTitle => 'Voting is Live';

  @override
  String get votingPhaseDesc =>
      'Project submissions are closed. The community is now voting.';

  @override
  String get eventClosedTitle => 'Event Has Ended';

  @override
  String get eventClosedDesc =>
      'This event is closed and no longer accepting project submissions.';

  @override
  String get eventNotStartedTitle => 'Event Not Started Yet';

  @override
  String get eventNotStartedDesc =>
      'This event hasn\'t opened for submissions yet. Check back soon.';

  @override
  String get eventArchivedTitle => 'Event Archived';

  @override
  String get eventArchivedDesc =>
      'This event has been archived and is no longer active.';

  @override
  String get basicInfoCard => 'Basic Info';

  @override
  String get techLinksCard => 'Tech & Links';

  @override
  String get categoriesCard => 'Categories';

  @override
  String get categoriesCardDesc =>
      'Select 1 to 3 categories that best describe your project.';

  @override
  String get selectCategory => 'Select a Category';

  @override
  String get addCategory => 'Add Category';

  @override
  String get categoryAdded => 'Category added';

  @override
  String get categoryRemoved => 'Category removed';

  @override
  String get maxCategoriesHint => 'You can select up to 3 categories.';

  @override
  String get noCategoriesAvailable => 'No categories available';

  @override
  String get noCategoriesSelected => 'No categories selected yet';

  @override
  String get projectImagesCard => 'Project Images';

  @override
  String get coverImageFormHint =>
      'Add a cover image to make your project stand out.';

  @override
  String get tapToAddCover => 'Tap to add cover image';

  @override
  String get extraImagesNote => 'You can add more images after submitting.';

  @override
  String get editProjectTitle => 'Edit Project';

  @override
  String get editProjectSubtitle =>
      'Update your project details, images, and categories.';

  @override
  String get saveProject => 'Save Changes';

  @override
  String get projectGallery => 'Project Gallery';

  @override
  String get projectImages => 'Project Images';

  @override
  String get coverImage => 'Cover Image';

  @override
  String get addCoverImage => 'Add Cover Image';

  @override
  String get changeCoverImage => 'Change';

  @override
  String get extraImages => 'Extra Images';

  @override
  String get addExtraImage => 'Add Image';

  @override
  String get removeImage => 'Remove';

  @override
  String get confirmRemoveCoverTitle => 'Remove Cover Image?';

  @override
  String get confirmRemoveCoverDesc =>
      'The cover image will be permanently deleted.';

  @override
  String get confirmRemoveImageTitle => 'Remove Image?';

  @override
  String get confirmRemoveImageDesc =>
      'This image will be permanently deleted.';

  @override
  String get deleteProject => 'Delete Project';

  @override
  String get confirmDeleteProjectTitle => 'Delete Project?';

  @override
  String get confirmDeleteProjectDesc =>
      'This will permanently delete your project and all its images. This action cannot be undone.';

  @override
  String get forceUpdateTitle => 'Update Required';

  @override
  String get forceUpdateButton => 'Download Update';
}

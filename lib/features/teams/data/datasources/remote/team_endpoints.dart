/// Centralized endpoint paths for the teams feature.
/// All paths are relative (no leading slash, no version prefix).
class TeamEndpoints {
  const TeamEndpoints._();

  static const String teams = 'teams';
  static const String myTeam = 'teams/my';
  static String leaveTeam(String teamId) => 'teams/$teamId/leave';
  static const String myInvitations = 'teams/invitations';

  static String teamById(String teamId) => 'teams/$teamId';

  static String teamInvitations(String teamId) =>
      'teams/$teamId/invitations';

  static String invitationById(String invitationId) =>
      'teams/invitations/$invitationId';

  static String teamMember(String teamId, String memberId) =>
      'teams/$teamId/members/$memberId';

  static String transferLeadership(String teamId) =>
      'teams/$teamId/transfer-leadership';

  static String cancelInvitation(String invitationId) =>
      'teams/invitations/$invitationId/cancel';
}

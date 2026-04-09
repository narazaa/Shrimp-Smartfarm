import '../models/team_member.dart';

class TeamController {
  List<TeamMember> getTeamMembers() {
    return [
      TeamMember(
        imagePath: 'assets/avartar1.jpg',
        name: 'นายนารา ปองรักษ์',
        studentId: '66543206048-1',
        role: '',
      ),
      TeamMember(
        imagePath: 'assets/avartar2.jpeg',
        name: 'นางสาววิลาสิณี  พรมมา',
        studentId: ' 66543206087-9',
        role: '',
      ),
      TeamMember(
        imagePath: 'assets/avartar3.png',
        name: 'นายบุญพัฒน์\t สมเพชร',
        studentId: '66543206046-5',
        role: '',
      ),
    ];
  }
}

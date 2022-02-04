// class Hobby {
//   final int id;
//   final String name;

//   Hobby({
//     this.id,
//     this.name,
//   });
// }

class HobbiesList {
  static final _hobbies = [
    'pet keeping',
    'martial arts',
    'singing/music',
    'outdoor games',
    'programing',
    'performing arts',
    'board games',
    'creative arts',
    'collecting',
    'reading/writing',
    'sewing/knitting/embroidery',
    'watching movies',
    'gaming',
    'culinary',
    'sports',
    'travelling',
    'photography',
    'DIY',
    'foreign languages',
    'gardening',
    'blogging',
    'indoor games',
    'volunteering',
    'shopping'
  ];

  static List<String> get hobbies {
    return [..._hobbies];
  }
}

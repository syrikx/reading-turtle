import '../../../domain/entities/book.dart';

/// Dummy data for tutorial screens
class TutorialDummyData {
  static final List<Book> sampleBooks = [
    Book(
      isbn: '9780439554930',
      title: 'Harry Potter and the Philosopher\'s Stone',
      author: 'J.K. Rowling',
      btLevel: 5.5,
      lexile: '880L',
      quiz: 15,
      imageUrl: 'https://via.placeholder.com/150x200/4CAF50/FFFFFF?text=Harry+Potter',
      hasWords: true,
    ),
    Book(
      isbn: '9780439139595',
      title: 'The Hunger Games',
      author: 'Suzanne Collins',
      btLevel: 5.3,
      lexile: '810L',
      quiz: 12,
      imageUrl: 'https://via.placeholder.com/150x200/2196F3/FFFFFF?text=Hunger+Games',
      hasWords: true,
    ),
    Book(
      isbn: '9780545010221',
      title: 'Diary of a Wimpy Kid',
      author: 'Jeff Kinney',
      btLevel: 3.5,
      lexile: '950L',
      quiz: 10,
      imageUrl: 'https://via.placeholder.com/150x200/FF9800/FFFFFF?text=Wimpy+Kid',
      hasWords: false,
    ),
    Book(
      isbn: '9780316015844',
      title: 'Twilight',
      author: 'Stephenie Meyer',
      btLevel: 4.9,
      lexile: '720L',
      quiz: 0,
      imageUrl: 'https://via.placeholder.com/150x200/9C27B0/FFFFFF?text=Twilight',
      hasWords: true,
    ),
    Book(
      isbn: '9780062073488',
      title: 'Wonder',
      author: 'R.J. Palacio',
      btLevel: 4.8,
      lexile: '790L',
      quiz: 8,
      imageUrl: 'https://via.placeholder.com/150x200/F44336/FFFFFF?text=Wonder',
      hasWords: true,
    ),
    Book(
      isbn: '9780385737951',
      title: 'The Fault in Our Stars',
      author: 'John Green',
      btLevel: 5.5,
      lexile: '850L',
      quiz: 11,
      imageUrl: 'https://via.placeholder.com/150x200/00BCD4/FFFFFF?text=TFIOS',
      hasWords: false,
    ),
  ];

  static final Book tutorialBook = Book(
    isbn: 'TUTORIAL001',
    title: 'The Great Tutorial Adventure',
    author: 'Reading Turtle Team',
    btLevel: 5.0,
    lexile: '800L',
    quiz: 5,
    imageUrl: 'https://via.placeholder.com/150x200/4CAF50/FFFFFF?text=Tutorial+Book',
    hasWords: true,
  );

  static final List<Map<String, dynamic>> sampleQuizQuestions = [
    {
      'question': 'What is the main character\'s name?',
      'choices': ['Harry', 'Ron', 'Hermione', 'Draco'],
      'correctAnswer': 0,
    },
    {
      'question': 'Where does Harry live with the Dursleys?',
      'choices': ['Hogwarts', 'Diagon Alley', 'Privet Drive', 'The Burrow'],
      'correctAnswer': 2,
    },
    {
      'question': 'What is Harry\'s house at Hogwarts?',
      'choices': ['Slytherin', 'Gryffindor', 'Ravenclaw', 'Hufflepuff'],
      'correctAnswer': 1,
    },
  ];

  static final List<Map<String, dynamic>> sampleWords = [
    {
      'word': 'adventure',
      'definition': 'An exciting or unusual experience',
      'example': 'Harry went on a great adventure.',
      'known': false,
      'bookmarked': false,
    },
    {
      'word': 'courage',
      'definition': 'The ability to do something that frightens one',
      'example': 'It takes courage to stand up to your enemies.',
      'known': true,
      'bookmarked': false,
    },
    {
      'word': 'mysterious',
      'definition': 'Difficult or impossible to understand or explain',
      'example': 'The castle was full of mysterious secrets.',
      'known': false,
      'bookmarked': true,
    },
    {
      'word': 'wizard',
      'definition': 'A person who has magical powers',
      'example': 'Harry is a young wizard.',
      'known': true,
      'bookmarked': true,
    },
    {
      'word': 'friendship',
      'definition': 'The emotions or conduct of friends',
      'example': 'The story shows the importance of friendship.',
      'known': false,
      'bookmarked': false,
    },
  ];

  static final List<Map<String, String>> sampleReadingSessions = [
    {'date': '2025-10-20', 'title': 'Harry Potter', 'minutes': '45'},
    {'date': '2025-10-21', 'title': 'Hunger Games', 'minutes': '30'},
    {'date': '2025-10-22', 'title': 'Wonder', 'minutes': '60'},
    {'date': '2025-10-23', 'title': 'Twilight', 'minutes': '25'},
  ];
}

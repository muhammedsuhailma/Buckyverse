final List<Map<String, dynamic>> mediaItems = [
  {
    "id": "1",
    "image": "assets/images/aotbaner.jpg",
    "title": "Attack on Titan",
    "category": "Anime",
    "type": "TV ANIME",
    "rating": "9.1",
    "year": "2013",
    "duration": "87 EPS",
    "genres": "Action,Drama,Fantasy",
    "similar": ["2", "6"],
    "description":
        "Humanity lives behind enormous walls to protect itself from giant Titans. After witnessing a devastating attack, Eren Yeager vows to destroy every Titan and uncover the truth behind their existence.",
  },

  {
    "id": "2",
    "image": "assets/images/demon.jpeg",
    "title": "Demon Slayer",
    "category": "Anime",
    "type": "TV ANIME",
    "rating": "8.7",
    "year": "2019",
    "duration": "63 EPS",
    "genres": "Action,Adventure,Fantasy",
    "similar": ["1", "6"],
    "description":
        "After his family is slaughtered by demons, Tanjiro Kamado sets out on a journey to become a Demon Slayer and find a cure for his sister Nezuko.",
  },

  {
    "id": "3",
    "image": "assets/images/interste.jpeg",
    "title": "Interstellar",
    "category": "Movies",
    "type": "MOVIE",
    "rating": "8.8",
    "year": "2014",
    "duration": "169 MIN",
    "genres": "Sci-Fi,Adventure,Drama",
    "similar": ["7"],
    "description":
        "A team of astronauts travels through a wormhole in search of a new home for humanity as Earth faces extinction.",
  },

  {
    "id": "4",
    "image": "assets/images/strange.jpeg",
    "title": "Stranger Things",
    "category": "Series",
    "type": "TV SERIES",
    "rating": "8.9",
    "year": "2016",
    "duration": "4 Seasons",
    "genres": "Sci-Fi,Adventure,Drama,Horror",
    "similar": ["5"],
    "description":
        "When a young boy disappears, a group of friends uncover secret experiments, supernatural forces, and a mysterious girl with incredible powers.",
  },

  {
    "id": "5",
    "image": "assets/images/squidgame.jpeg",
    "title": "Squid Game",
    "category": "K-Drama",
    "type": "K-DRAMA",
    "rating": "8.5",
    "year": "2021",
    "duration": "2 Seasons",
    "genres": "Horror,Thriller,Drama",
    "similar": ["4"],
    "description":
        "Hundreds of people burdened by debt compete in deadly children's games for a life-changing cash prize.",
  },

  {
    "id": "6",
    "image": "assets/images/onepiece.jpeg",
    "title": "One Piece",
    "category": "Anime",
    "type": "TV ANIME",
    "rating": "9.2",
    "year": "1999",
    "duration": "1100+ EPS",
    "genres": "Action,Adventure,Drama",
    "similar": ["1", "2"],
    "description":
        "Monkey D. Luffy and his pirate crew sail across the Grand Line in search of the legendary treasure known as the One Piece.",
  },

  {
    "id": "7",
    "image": "assets/images/batm.jpeg",
    "title": "The Batman",
    "category": "Movies",
    "type": "MOVIE",
    "rating": "8.1",
    "year": "2022",
    "duration": "176 MIN",
    "genres": "Action,Superhero,Thriller",
    "similar": ["3"],
    "description":
        "Batman investigates a series of murders committed by the Riddler while uncovering corruption hidden deep within Gotham City.",
  },
];

int getCategoryCount(String category) {
  return mediaItems.where((item) => item["category"] == category).length;
}

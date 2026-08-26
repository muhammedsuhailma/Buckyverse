import 'package:flutter_test/flutter_test.dart';
import 'package:bucky_verse/providers/api_provider.dart';
import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:bucky_verse/models/bucket_item.dart';

void main() {
  test('ApiProvider initializes with empty state and false loading flags', () {
    final provider = ApiProvider();
    expect(provider.anime, isEmpty);
    expect(provider.movies, isEmpty);
    expect(provider.series, isEmpty);
    expect(provider.kdramas, isEmpty);
    expect(provider.exploreItems, isEmpty);
    expect(provider.searchAnime, isEmpty);
    expect(provider.searchMovies, isEmpty);
    expect(provider.searchSeries, isEmpty);
    expect(provider.searchKdramas, isEmpty);
    expect(provider.searchItems, isEmpty);
    expect(provider.isLoading, isFalse);
    expect(provider.isAnimeLoading, isFalse);
    expect(provider.isMoviesLoading, isFalse);
    expect(provider.isSeriesLoading, isFalse);
    expect(provider.isKdramasLoading, isFalse);
    expect(provider.isSearching, isFalse);
    expect(provider.isLanguageLoading, isFalse);
    expect(provider.languageCache, isEmpty);
  });

  test('Clearing search does not affect home items', () async {
    final provider = ApiProvider();
    await provider.searchAll("");
    expect(provider.searchItems, isEmpty);
    expect(provider.anime, isEmpty);
    expect(provider.movies, isEmpty);
    expect(provider.series, isEmpty);
    expect(provider.kdramas, isEmpty);
  });

  test('getCachedDataset returns null when cache is empty', () {
    final provider = ApiProvider();
    expect(provider.getCachedDataset("Movies", "hi"), isNull);
  });

  test('Cached language datasets are stored and retrieved correctly', () {
    final provider = ApiProvider();
    final mockHindiMovies = [
      {
        "id": "1",
        "title": "Hindi Movie 1",
        "category": "Movies",
        "language": "Hindi",
      },
    ];

    provider.languageCache["Movies-hi"] = mockHindiMovies;
    final cached = provider.getCachedDataset("Movies", "hi");

    expect(cached, isNotNull);
    expect(cached!.length, equals(1));
    expect(cached.first["title"], equals("Hindi Movie 1"));
    expect(cached.first["language"], equals("Hindi"));
  });

  group('BucketProvider Contextual Statistics', () {
    late BucketProvider provider;

    final anime1 = BucketItem(
      id: 'a1',
      data: {'title': 'Attack on Titan', 'type': 'ANIME'},
      status: 'Planning',
      isFavorite: false,
    );
    final anime2 = BucketItem(
      id: 'a2',
      data: {'title': 'Demon Slayer', 'type': 'ANIME'},
      status: 'Planning',
      isFavorite: true,
    );
    final anime3 = BucketItem(
      id: 'a3',
      data: {'title': 'Naruto Shippuden', 'type': 'ANIME'},
      status: 'Planning',
      isFavorite: false,
    );
    final anime4 = BucketItem(
      id: 'a4',
      data: {'title': 'Jujutsu Kaisen', 'type': 'ANIME'},
      status: 'Watching',
      isFavorite: false,
    );
    final anime5 = BucketItem(
      id: 'a5',
      data: {'title': 'One Piece', 'type': 'ANIME'},
      status: 'Watching',
      isFavorite: false,
    );
    final anime6 = BucketItem(
      id: 'a6',
      data: {'title': 'Death Note', 'type': 'ANIME'},
      status: 'Completed',
      isFavorite: false,
    );

    final movie1 = BucketItem(
      id: 'm1',
      data: {'title': 'Inception', 'type': 'MOVIE'},
      status: 'Planning',
      isFavorite: false,
    );
    final movie2 = BucketItem(
      id: 'm2',
      data: {'title': 'Interstellar', 'type': 'MOVIE'},
      status: 'Watching',
      isFavorite: false,
    );
    final movie3 = BucketItem(
      id: 'm3',
      data: {'title': 'The Dark Knight', 'type': 'MOVIE'},
      status: 'Watching',
      isFavorite: false,
    );
    final movie4 = BucketItem(
      id: 'm4',
      data: {'title': 'Oppenheimer', 'type': 'MOVIE'},
      status: 'Completed',
      isFavorite: false,
    );

    final series1 = BucketItem(
      id: 's1',
      data: {'title': 'Breaking Bad', 'type': 'SERIES'},
      status: 'Completed',
      isFavorite: true,
    );
    final series2 = BucketItem(
      id: 's2',
      data: {'title': 'Stranger Things', 'type': 'SERIES'},
      status: 'Watching',
      isFavorite: false,
    );
    final series3 = BucketItem(
      id: 's3',
      data: {'title': 'Dark', 'type': 'SERIES'},
      status: 'Planning',
      isFavorite: false,
    );
    final series4 = BucketItem(
      id: 's4',
      data: {'title': 'Severance', 'type': 'SERIES'},
      status: 'Planning',
      isFavorite: false,
    );

    final kdrama1 = BucketItem(
      id: 'k1',
      data: {'title': 'Crash Landing on You', 'type': 'DRAMA'},
      status: 'Completed',
      isFavorite: true,
    );
    final kdrama2 = BucketItem(
      id: 'k2',
      data: {'title': 'Goblin', 'type': 'DRAMA'},
      status: 'Completed',
      isFavorite: false,
    );
    final kdrama3 = BucketItem(
      id: 'k3',
      data: {'title': 'Vincenzo', 'type': 'DRAMA'},
      status: 'Watching',
      isFavorite: false,
    );
    final kdrama4 = BucketItem(
      id: 'k4',
      data: {'title': 'Sweet Home', 'type': 'DRAMA'},
      status: 'Planning',
      isFavorite: false,
    );

    setUp(() {
      provider = BucketProvider();
      provider.bucketItems.addAll([
        anime1,
        anime2,
        anime3,
        anime4,
        anime5,
        anime6,
        movie1,
        movie2,
        movie3,
        movie4,
        series1,
        series2,
        series3,
        series4,
        kdrama1,
        kdrama2,
        kdrama3,
        kdrama4,
      ]);
    });

    test('Global statistics for All Universes', () {
      provider.changeCategory('All');

      expect(provider.totalCount, equals(18));
      expect(provider.planningCount, equals(7));
      expect(provider.watchingCount, equals(6));
      expect(provider.completedCount, equals(5));
      expect(provider.favoritesCount, equals(3));
    });

    test('Statistics for Anime category', () {
      provider.changeCategory('Anime');

      expect(provider.totalCount, equals(6));
      expect(provider.planningCount, equals(3));
      expect(provider.watchingCount, equals(2));
      expect(provider.completedCount, equals(1));
      expect(provider.favoritesCount, equals(1));
    });

    test('Statistics for Movies category', () {
      provider.changeCategory('Movies');

      expect(provider.totalCount, equals(4));
      expect(provider.planningCount, equals(1));
      expect(provider.watchingCount, equals(2));
      expect(provider.completedCount, equals(1));
      expect(provider.favoritesCount, equals(0));
    });

    test('Statistics for Series category', () {
      provider.changeCategory('Series');

      expect(provider.totalCount, equals(4));
      expect(provider.planningCount, equals(2));
      expect(provider.watchingCount, equals(1));
      expect(provider.completedCount, equals(1));
      expect(provider.favoritesCount, equals(1));
    });

    test('Statistics for K-Drama category', () {
      provider.changeCategory('K-Drama');

      expect(provider.totalCount, equals(4));
      expect(provider.planningCount, equals(1));
      expect(provider.watchingCount, equals(1));
      expect(provider.completedCount, equals(2));
      expect(provider.favoritesCount, equals(1));
    });

    test('Statistics calculate from visible results when search query is active', () {
      provider.changeCategory('All');
      provider.changeSearch('Titan'); // Matches "Attack on Titan" (Anime, Planning)

      expect(provider.totalCount, equals(1));
      expect(provider.planningCount, equals(1));
      expect(provider.watchingCount, equals(0));
      expect(provider.completedCount, equals(0));
      expect(provider.favoritesCount, equals(0));

      provider.changeSearch('Dark'); // Matches "The Dark Knight" (Movie) and "Dark" (Series)
      expect(provider.totalCount, equals(2));
      expect(provider.planningCount, equals(1)); // Dark
      expect(provider.watchingCount, equals(1)); // The Dark Knight

      // Combined with category filter
      provider.changeCategory('Movies');
      expect(provider.totalCount, equals(1)); // Only The Dark Knight
      expect(provider.watchingCount, equals(1));
      expect(provider.planningCount, equals(0));
    });

    test('Global getters always reflect entire bucket regardless of active category or search', () {
      provider.changeCategory('Anime');
      provider.changeSearch('Demon');

      expect(provider.totalCount, equals(1));
      expect(provider.globalTotalCount, equals(18));
      expect(provider.globalPlanningCount, equals(7));
      expect(provider.globalWatchingCount, equals(6));
      expect(provider.globalCompletedCount, equals(5));
      expect(provider.globalFavoritesCount, equals(3));
    });
  });
}


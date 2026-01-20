import 'database.dart';

// DAO Class - Data Access Object
class ChannelDao {
  Future<List<Channel>> getAllChannels() => AppDatabase.getAllChannels();

  Future<List<Channel>> searchChannels(String query) => AppDatabase.searchChannels(query);

  Future<List<String>> getAllGroups() => AppDatabase.getAllGroups();

  Future<void> insertChannels(List<Channel> channelList) => AppDatabase.insertChannels(channelList);

  Future<void> deleteAllChannels() => AppDatabase.deleteAllChannels();

  Future<int> getTotalChannelCount() => AppDatabase.getTotalChannelCount();

  Future<Map<String, int>> getGroupStatistics() => AppDatabase.getGroupStatistics();
}

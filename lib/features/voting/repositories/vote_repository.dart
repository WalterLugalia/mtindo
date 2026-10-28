
import '../../../core/errors/failure.dart';
import '../services/vote_service.dart';

class VoteRepository {
  final VoteService _service;

  VoteRepository(this._service);

  Future<int> getVoteCount(int productId) =>
      _guard(() => _service.getVoteCount(productId));

  Future<bool> hasVoted(int productId) =>
      _guard(() => _service.hasVoted(productId));

  Future<void> addVote(int productId) =>
      _guard(() => _service.addVote(productId));

  Future<void> removeVote(int productId) =>
      _guard(() => _service.removeVote(productId));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }
}
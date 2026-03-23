import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class SearchTeamsParams extends Equatable {
  const SearchTeamsParams({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

class SearchTeams extends UseCase<List<TeamEntity>, SearchTeamsParams> {
  SearchTeams(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, List<TeamEntity>>> call(SearchTeamsParams params) {
    return repository.searchTeams(query: params.query);
  }
}

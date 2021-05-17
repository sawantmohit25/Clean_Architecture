import 'package:clean_architecture_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class InputConverter{
  Either<Failure,int> stringToUnsigneInteger(String str){
    try{
      final integer=int.parse(str);
      if(integer<0) throw FormatException();
      return Right(integer);
    }
    on FormatException{
      return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failure{}
import 'package:clean_architecture_app/core/errors/failures.dart';
import 'package:clean_architecture_app/core/usecases/usecase.dart';
import 'package:clean_architecture_app/core/util/input_converter.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';

class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia{}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia{}

class MockInputConverter extends Mock implements InputConverter{}

void main(){
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp((){
    mockGetConcreteNumberTrivia=MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia=MockGetRandomNumberTrivia();
    mockInputConverter=MockInputConverter();
    bloc=NumberTriviaBloc(concrete:mockGetConcreteNumberTrivia, random:mockGetRandomNumberTrivia, inputConverter:mockInputConverter);
  });

  test('initial state should be empty',(){
    //assert
    expect(bloc.initialState,Empty());
  });
  
  group('getTriviaForConcreteNumber',(){
    final tNumberString='1';
    final tNumber=1;
    final tNumberTrivia=NumberTrivia(text:'test trivia', number: 1);

    void setupMockInputConverterSuccess(){
      when(mockInputConverter.stringToUnsigneInteger(any)).thenReturn(Right(tNumber));
    }
    test('should call the Input Converter to validate and covert string to an unsigned integer', ()async{
      //arrange
      setupMockInputConverterSuccess();
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsigneInteger(any));
      //assert
      verify(mockInputConverter.stringToUnsigneInteger(tNumberString));
    });

    test('should emit error when the input is invalid',()async{
      //arrange
      when(mockInputConverter.stringToUnsigneInteger(any)).thenReturn(Left(InvalidInputFailure()));
      //assert later
      final expected=[
        Empty(),
        Error(message:INVALID_INPUT_FAILURE_MESSAGE),
      ];
      expectLater(bloc.asBroadcastStream(),emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete use case',()async{
      //arrange
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any)).thenAnswer((_)async =>Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));

      //assert
      verify(mockGetConcreteNumberTrivia(Params(number:tNumber)));
    });

    test('should emit [Loading,Loaded] when the data is gotten successfully',()async{
      //arrange
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any)).thenAnswer((_)async =>Right(tNumberTrivia));
      //assert later
      final expected=[
        Empty(),
        Loading(),
        Loaded(trivia:tNumberTrivia)
      ];
      expectLater(bloc.asBroadcastStream(),emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading,Error] when getting data fails',()async{
      //arrange
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any)).thenAnswer((_)async =>Left(ServerFailure()));
      //assert later
      final expected=[
        Empty(),
        Loading(),
        Error(message:SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc.asBroadcastStream(),emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading,Error] with a proper message of error when getting data fails',()async{
      //arrange
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any)).thenAnswer((_)async =>Left(CacheFailure()));
      //assert later
      final expected=[
        Empty(),
        Loading(),
        Error(message:CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc.asBroadcastStream(),emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

  });

  group('getTriviaForRandomNumber',(){

    final tNumberTrivia=NumberTrivia(text:'test trivia', number: 1);

    test('should get data from the random use case',()async{
      //arrange
      when(mockGetRandomNumberTrivia(any)).thenAnswer((_)async =>Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(any));

      //assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading,Loaded] when the data is gotten successfully',()async{
      //arrange
      when(mockGetRandomNumberTrivia(any)).thenAnswer((_)async =>Right(tNumberTrivia));
      //assert later
      final expected=[
        Empty(),
        Loading(),
        Loaded(trivia:tNumberTrivia)
      ];
      expectLater(bloc.asBroadcastStream(),emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading,Error] when getting data fails',()async{
      //arrange
      when(mockGetRandomNumberTrivia(any)).thenAnswer((_)async =>Left(ServerFailure()));
      //assert later
      final expected=[
        Empty(),
        Loading(),
        Error(message:SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc.asBroadcastStream(),emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading,Error] with a proper message of error when getting data fails',()async{
      //arrange
      when(mockGetRandomNumberTrivia(any)).thenAnswer((_)async =>Left(CacheFailure()));
      //assert later
      final expected=[
        Empty(),
        Loading(),
        Error(message:CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc.asBroadcastStream(),emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });

  });
}
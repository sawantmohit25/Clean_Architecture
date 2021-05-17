import 'package:clean_architecture_app/core/errors/exceptions.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:http/http.dart'as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client{}

void main(){
  NumberTriviaRemoteDataSourceImpl dataSourceImpl;
  MockHttpClient mockHttpClient;
  setUp((){
    mockHttpClient=MockHttpClient();
    dataSourceImpl=NumberTriviaRemoteDataSourceImpl(client:mockHttpClient);
  });

  void setupMockHttpClientSuccess200(){
    when(mockHttpClient.get(any,headers:anyNamed('headers'))).thenAnswer((_)async =>http.Response(fixture('trivia.json'),200));
  }

  void setupMockHttpClientFailure404(){
    when(mockHttpClient.get(any,headers:anyNamed('headers'))).thenAnswer((_)async =>http.Response('Something went wrong',404));
  }

  group('getConcreteNumberTrivia',(){
    final tNumber=1;
    final tNumberTriviaModel=NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('should perform a get request on url with no being the endpoint and with the application/json header', ()async{
      //arrange
      setupMockHttpClientSuccess200();
      //act
      dataSourceImpl.getConcreteNumberTrivia(tNumber);
      //assert
      verify(mockHttpClient.get('http://numbersapi.com/$tNumber',headers:{'Content-Type':'application/json'}));
    });

    test('should return number trivia when the response code is 200(success)', ()async{
      //arrange
      setupMockHttpClientSuccess200();
      //act
      final result=await dataSourceImpl.getConcreteNumberTrivia(tNumber);
      //assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a server exception when the response code is 404 or other', ()async{
      //arrange
      setupMockHttpClientFailure404();
      //act
      final call=dataSourceImpl.getConcreteNumberTrivia;
      //assert
      expect(()=>call(tNumber),throwsA(isInstanceOf<ServerException>()));
    });
  });

  group('getRandomNumberTrivia',(){
    final tNumberTriviaModel=NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('should perform a get request on url with no being the endpoint and with the application/json header', ()async{
      //arrange
      setupMockHttpClientSuccess200();
      //act
      dataSourceImpl.getRandomNumberTrivia();
      //assert
      verify(mockHttpClient.get('http://numbersapi.com/random',headers:{'Content-Type':'application/json'}));
    });

    test('should return number trivia when the response code is 200(success)', ()async{
      //arrange
      setupMockHttpClientSuccess200();
      //act
      final result=await dataSourceImpl.getRandomNumberTrivia();
      //assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a server exception when the response code is 404 or other', ()async{
      //arrange
      setupMockHttpClientFailure404();
      //act
      final call=dataSourceImpl.getRandomNumberTrivia();
      //assert
      expect(()=>call,throwsA(isInstanceOf<ServerException>()));
    });
  });
}

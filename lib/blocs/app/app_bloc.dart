import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_auth/repositories/auth_repository.dart';

import '../../models/user_model.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthRepository _authRepository;
  StreamSubscription<User>? _userSubscription;

  AppBloc({required AuthRepository authRepository})
      : _authRepository=authRepository,
        super(
          authRepository.currentUser.isNotEmpty
            ? AppState.authenticated(authRepository.currentUser)
            : const AppState.unauthenticated(),
      ){
   on<AppUserChanged>(_onUserChanged);
   on<AppLogoutRequested>(_onLogoutRequested);
   
   _userSubscription=_authRepository.user.listen((user)=>
    add(AppUserChanged(user)),
   );
  }

  void _onUserChanged(
      AppUserChanged event,
      Emitter<AppState> emit,
      ) {
    emit(event.user.isNotEmpty
        ? AppState.authenticated(event.user)
        :const AppState.unauthenticated());
  }

  void _onLogoutRequested(
      AppLogoutRequested event,
      Emitter<AppState> emit,
      ){
    unawaited(_authRepository.logOut());
  }

  @override
  Widget build(BuildContext context){
    final user= context.select((AppBloc bloc) => bloc.state.user);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(onPressed: (){
            context.read<AppBloc>().add(AppLogoutRequested(),
            );
          },
              icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Align(
        alignment: const Alignment(0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
              user.photo!= null ? NetworkImage(user.photo!): null,
                child: user.photo== null ? const Icon(Icons.person):null),
        const SizedBox(height: 10),
        Text(user.email ?? '')
          ],
        ),
      ),
    );
  }
}

import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

class MyUser extends Equatable  {
	final String userId;
	final String email;
	final String name;

	const MyUser({
		required this.userId,
		required this.email,
		required this.name
	});

	static const empty = MyUser(
		userId: '', 
		email: '', 
		name: ''
	);

	MyUser copyWith({
		String? userId,
		String? email,
		String? name
	}) {
		return MyUser(
			userId: userId ?? this.userId, 
			email: email ?? this.email, 
			name: name ?? this.name
		);
	}

	MyUserEntity toEntity() {
		return MyUserEntity(
			userId: userId, 
			email: email, 
			name: name
		);
	}

	static MyUser fromEntity(MyUserEntity entity) {
		return MyUser(
			userId: entity.userId, 
			email: entity.email, 
			name: entity.name
		);
	}
	
	@override
	List<Object?> get props => [userId, email, name];
}
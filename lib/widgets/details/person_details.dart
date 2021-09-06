import 'package:flutter/material.dart';
import 'package:goribernetflix/models/person.dart';
import 'package:goribernetflix/widgets/detail_shell.dart';

class PersonDetails extends StatelessWidget {
  final Person person;

  const PersonDetails(
    this.person, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailShell(
      title: person.name,
      description: person.biography,
      imageUris: person.imageUris,
    );
  }
}

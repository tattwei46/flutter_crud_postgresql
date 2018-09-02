import 'package:aqueduct/aqueduct.dart';
import 'package:heroes/heroes.dart';
import 'package:heroes/model/hero.dart';

class HeroesController extends ResourceController {
  HeroesController(this.context);

  final ManagedContext context;

    // final _heroes = [
    //   {'id': 11, 'name': 'Captain America'},
    //   {'id': 12, 'name': 'Ironman'},
    //   {'id': 13, 'name': 'Wonder Woman'},
    //   {'id': 14, 'name': 'Hulk'},
    //   {'id': 15, 'name': 'Black Widow'},
    // ];

  @Operation.post()
  Future<Response> createHero(@Bind.body() Hero inputHero) async {
    final query = Query<Hero>(context)
      ..values = inputHero;

    final insertedHero = await query.insert();

    return Response.ok(insertedHero);
  }

  @Operation.delete('id')
  Future<Response> deleteHeroByID(@Bind.path('id') int id) async {
    final heroQuery = Query<Hero>(context)..where((h) => h.id).equalTo(id);
    final hero = await heroQuery.delete();
    if (hero == null) {
      return Response.notFound();
    } 
    return Response.ok(hero);
  }

  @Operation.put('id')
  Future<Response> updateHeroById(@Bind.path('id') int id ,@Bind.body() Hero inputHero) async {
    final heroQuery = Query<Hero>(context)
      ..where((h) => h.id).equalTo(id)
      ..values = inputHero;
    final hero = await heroQuery.updateOne();
    if (hero == null) {
      return Response.notFound();
    } 
    return Response.ok(hero);
  }

  @Operation.get()
  Future<Response> getAllHeroes() async {
    final heroQuery = Query<Hero>(context);
    final heroes = await heroQuery.fetch();

    return Response.ok(heroes);
  }

  @Operation.get('id')
  Future<Response> getHeroByID(@Bind.path('id') int id) async {
    final heroQuery = Query<Hero>(context)..where((h) => h.id).equalTo(id);
    final hero = await heroQuery.fetchOne();
    if (hero == null) {
      return Response.notFound();
    } 
    return Response.ok(hero);
  }
}



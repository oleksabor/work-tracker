import 'package:equatable/equatable.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object> get props => [];
}

class ItemAdded extends ItemEvent {}

class ItemQtyChanged extends ItemEvent {
  final int qty;
  ItemQtyChanged(this.qty);

  @override
  List<Object> get props => [qty];
}

class ItemWeightChanged extends ItemEvent {
  final double weight;
  ItemWeightChanged(this.weight);

  @override
  List<Object> get props => [weight];
}

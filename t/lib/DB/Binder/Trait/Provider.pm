package # hide from PAUSE
    DB::Binder::Trait::Provider;
use strict;
use warnings;

use Method::Traits ':for_providers';

sub PrimaryKey : OverwritesMethod {
    my ($meta, $method_name, $column_name) = @_;
    Col($meta, $method_name, $column_name);
}

sub Col : OverwritesMethod {
    my ($meta, $method_name, $column_name) = @_;

    $column_name ||= $method_name;

    die 'A slot already exists for ('.$column_name.')'
        if $meta->has_slot( $column_name )
        || $meta->has_slot_alias( $column_name );

    $meta->add_slot( $column_name, eval 'package '.$meta->name.';sub {};' );
    $meta->add_method( $method_name, sub { $_[0]->{ $column_name } } );
}

sub HasOne : OverwritesMethod  {
    my ($meta, $method_name, $related_class, $column_name) = @_;

    $column_name ||= $method_name;

    die 'A slot already exists for ('.$column_name.')'
        if $meta->has_slot( $column_name )
        || $meta->has_slot_alias( $column_name );

    $meta->add_slot( $column_name, eval 'package '.$meta->name.';sub { '.$related_class.'->new };' );
    $meta->add_method( $method_name, sub { $_[0]->{ $column_name } } );
}

sub HasMany : OverwritesMethod {
    my ($meta, $method_name, $related_class, $related_column_name) = @_;

    my $column_name = $method_name;

    die 'A slot already exists for ('.$column_name.')'
        if $meta->has_slot( $column_name )
        || $meta->has_slot_alias( $column_name );

    $meta->add_slot( $column_name, eval 'package '.$meta->name.';sub { [] };' );
    $meta->add_method( $method_name, sub { @{ $_[0]->{ $column_name } } } );
}

1;
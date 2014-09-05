#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::JobControl::Helper::Project::Formular;

use strict;
use warnings;

use File::Spec;
use File::Path;
use YAML;
use Rex::JobControl::Helper::Chdir;
use Data::Dumper;

sub new {
  my $that  = shift;
  my $proto = ref($that) || $that;
  my $self  = {@_};

  bless( $self, $proto );

  $self->load;

  return $self;
}

sub name        { (shift)->{formular_configuration}->{name} }
sub description { (shift)->{formular_configuration}->{description} }
sub project     { (shift)->{project} }
sub directory   { (shift)->{directory} }

sub load {
  my ($self) = @_;

  if ( -f $self->_config_file() ) {
    $self->{formular_configuration} = YAML::LoadFile( $self->_config_file );

    my $steps_file = File::Spec->catfile( $self->project->project_path(),
      "formulars", $self->{directory}, "steps.yml" );

    $self->{steps} = YAML::LoadFile($steps_file);
  }
}

sub _config_file {
  my ($self) = @_;
  return File::Spec->catfile( $self->project->project_path(),
    "formulars", $self->{directory}, "formular.conf.yml" );
}

sub steps {
  my ($self) = @_;
  return $self->{steps}->{formulars};
}

sub formulars {
  my ($self) = @_;
  return $self->{steps}->{formulars};
}

sub create {
  my ( $self, %data ) = @_;

  my $form_path = File::Spec->catdir( $self->project->project_path,
    "formulars", $self->{directory} );

  $self->project->app->log->debug(
    "Creating new formular $self->{directory} in $form_path.");

  File::Path::make_path($form_path);

  my $steps = $data{steps};

  delete $data{directory};
  delete $data{steps};

  my $form_configuration = {%data};

  YAML::DumpFile( "$form_path/formular.conf.yml", $form_configuration );
  YAML::DumpFile( "$form_path/steps.yml", $steps );
}

1;

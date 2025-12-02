CREATE TABLE score_history (
  datetime timestamp NOT NULL,
  branch text NOT NULL,
  commit text NOT NULL,
  domain text NOT NULL,
  product_name text NOT NULL,
  id uuid NOT NULL,
  query text NOT NULL,
  mass numeric NOT NULL,
  elements text NOT NULL,
  lifecycle_step text NOT NULL,
  lifecycle_step_geozone text NOT NULL,
  impact text NOT NULL,
  value numeric NOT NULL,
  norm_value_ecs numeric NOT NULL
);

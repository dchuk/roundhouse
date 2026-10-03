//! Inline primitive JSON must use an encoder present in the compiled tree.
#[path = "support/emit_and_run.rs"]
mod emit_and_run;

fn app() -> emit_and_run::Overlay {
    emit_and_run::empty_app()
        .write("app/controllers/application_controller.rb", "class ApplicationController < ActionController::Base\nend\n")
        .write("db/schema.rb", "ActiveRecord::Schema.define do\n  create_table \"widgets\", force: :cascade do |t|\n    t.string \"name\"\n  end\nend\n")
        .write("config/routes.rb", "Rails.application.routes.draw do\n  get \"/payload\", to: \"payloads#show\"\n  get \"/list\", to: \"payloads#index\"\nend\n")
        .write("app/controllers/payloads_controller.rb", r#"class PayloadsController < ApplicationController
  def show
    render json: { message: "hello\n\"world\"", count: 2, active: true, missing: nil, nested: { tags: ["one", "two"], empty: [], object: {} } }, status: 202
  end
  def index
    render json: [{ name: "first", count: 1 }, { name: "second", count: 2 }]
  end
end
"#)
}

const ASSERTIONS: &str = r#"
require_relative "app/controllers/payloads_controller"
controller = PayloadsController.new
controller.process_action(:show)
raise "wrong status" unless controller.status == 202
raise "wrong content type" unless controller.content_type == "application/json"
raise controller.body unless controller.body == '{"message":"hello\n\"world\"","count":2,"active":true,"missing":null,"nested":{"tags":["one","two"],"empty":[],"object":{}}}'
controller = PayloadsController.new
controller.process_action(:index)
raise controller.body unless controller.body == '[{"name":"first","count":1},{"name":"second","count":2}]'
puts "primitive JSON passed"
"#;

#[test]
fn inline_primitive_json_runs() {
    app().run_ruby(ASSERTIONS).assert_passes();
}

#[test]
fn a_nested_time_keeps_rails_json_serialization() {
    app()
        .write("app/controllers/payloads_controller.rb", r#"class PayloadsController < ApplicationController
  def show
    render json: { at: Time.utc(2026, 7, 1, 12, 34, 56) }
  end
  def index
    head :no_content
  end
end
"#)
        .run_ruby(r#"
require_relative "app/controllers/payloads_controller"
controller = PayloadsController.new
controller.process_action(:show)
raise controller.body unless controller.body == '{"at":"2026-07-01T12:34:56.000Z"}'
"#)
        .assert_passes();
}

#[test]
#[ignore = "requires the Spinel toolchain"]
fn inline_primitive_json_runs_on_spinel() {
    app().run_spinel(ASSERTIONS).assert_passes();
}

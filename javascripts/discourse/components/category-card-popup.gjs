import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import dIcon from "discourse-common/helpers/d-icon";

export default class CategoryCardPopup extends Component {
  @tracked isVisible = false;

  get bannerStyle() {
    const bg = this.args.category?.uploaded_background?.url;
    if (bg) {
      return `background-image: url('${bg}')`;
    }
    return `background-color: #${this.args.category?.color || "888888"}`;
  }

  get logoCircleStyle() {
    return `background-color: #${this.args.category?.color || "888888"}`;
  }

  @action
  show() {
    this.isVisible = true;
  }

  @action
  hide() {
    this.isVisible = false;
  }

  <template>
    <span
      class="category-info"
      {{on "mouseenter" this.show}}
      {{on "mouseleave" this.hide}}
    >
      <a href="/n/{{@category.slug}}" class="category-link-wrapper">
        {{#if @category.uploaded_logo.url}}
          <span class="badge-category has-logo">
            <img
              src={{@category.uploaded_logo.url}}
              class="category-logo"
              alt=""
            />
          </span>
        {{else}}
          <span class="badge-category" style={{this.logoCircleStyle}}>
            {{#if @category.icon}}
              {{dIcon @category.icon class="category-icon"}}
            {{/if}}
          </span>
        {{/if}}
        <span class="category-slug">n/{{@category.slug}}</span>
      </a>

      {{#if this.isVisible}}
        <div class="category-popup-card">
          <div class="category-popup-card__banner" style={{this.bannerStyle}}></div>
          <div class="category-popup-card__body">
            <div class="category-popup-card__header">
              {{#if @category.uploaded_logo.url}}
                <img
                  src={{@category.uploaded_logo.url}}
                  class="category-popup-card__logo"
                  alt=""
                />
              {{else}}
                <span
                  class="category-popup-card__logo-circle"
                  style={{this.logoCircleStyle}}
                >
                  {{#if @category.icon}}
                    {{dIcon @category.icon}}
                  {{/if}}
                </span>
              {{/if}}
              <span class="category-popup-card__name">
                n/{{@category.slug}}
              </span>
            </div>
            {{#if @category.description_text}}
              <p class="category-popup-card__description">
                {{@category.description_text}}
              </p>
            {{/if}}
            <div class="category-popup-card__stats">
              <div class="category-popup-card__stat">
                <span class="category-popup-card__stat-value">
                  {{@category.topic_count}}
                </span>
                <span class="category-popup-card__stat-label">Topics</span>
              </div>
              <div class="category-popup-card__stat">
                <span class="category-popup-card__stat-value">
                  {{@category.post_count}}
                </span>
                <span class="category-popup-card__stat-label">Posts</span>
              </div>
            </div>
          </div>
        </div>
      {{/if}}
    </span>
  </template>
}

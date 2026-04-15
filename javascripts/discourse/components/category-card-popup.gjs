import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { cancel, later } from "@ember/runloop";
import dIcon from "discourse/helpers/d-icon";
import DiscourseURL from "discourse/lib/url";

export default class CategoryCardPopup extends Component {
  @tracked isVisible = false;
  @tracked popupTop = 0;
  @tracked popupLeft = 0;
  _hideTimer = null;

  willDestroy() {
    super.willDestroy(...arguments);
    if (this._hideTimer) {
      cancel(this._hideTimer);
    }
  }

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

  get popupStyle() {
    return `top: ${this.popupTop}px; left: ${this.popupLeft}px;`;
  }

  get portalTarget() {
    return document.body;
  }

  @action
  show(event) {
    if (this._hideTimer) {
      cancel(this._hideTimer);
      this._hideTimer = null;
    }
    const rect = event.currentTarget.getBoundingClientRect();
    this.popupTop = rect.bottom + window.scrollY + 8;
    this.popupLeft = rect.left + window.scrollX;
    this.isVisible = true;
  }

  @action
  scheduleHide() {
    this._hideTimer = later(
      this,
      () => {
        this.isVisible = false;
        this._hideTimer = null;
      },
      100
    );
  }

  @action
  cancelHide() {
    if (this._hideTimer) {
      cancel(this._hideTimer);
      this._hideTimer = null;
    }
  }

  @action
  navigate(event) {
    event.preventDefault();
    DiscourseURL.routeTo(`/n/${this.args.category.slug}`);
  }

  <template>
    <span
      class="category-info"
      {{on "mouseenter" this.show}}
      {{on "mouseleave" this.scheduleHide}}
    >
      <a
        href="/n/{{@category.slug}}"
        class="category-link-wrapper"
        {{on "click" this.navigate}}
      >
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
    </span>

    {{#if this.isVisible}}
      {{#in-element this.portalTarget insertBefore=null}}
        <div
          class="category-popup-card"
          style={{this.popupStyle}}
          {{on "mouseenter" this.cancelHide}}
          {{on "mouseleave" this.scheduleHide}}
        >
          <div
            class="category-popup-card__banner"
            style={{this.bannerStyle}}
          ></div>
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
              <a
                href="/n/{{@category.slug}}"
                class="category-popup-card__name"
                {{on "click" this.navigate}}
              >
                n/{{@category.slug}}
              </a>
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
      {{/in-element}}
    {{/if}}
  </template>
}

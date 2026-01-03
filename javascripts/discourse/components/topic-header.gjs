import Component from "@glimmer/component";
import { service } from "@ember/service";
import categoryLink from "discourse/helpers/category-link";
import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import and from "truth-helpers/helpers/and";
import dIcon from "discourse-common/helpers/d-icon";

export default class TopicHeader extends Component {
  @service router;

  get showCategory() {
    // Don't show category info when already viewing a specific category
    const currentRoute = this.router.currentRoute;
    return !currentRoute?.attributes?.category;
  }

  <template>
    <div class="topic-card__header">
      {{#if (and @topic.category this.showCategory)}}
        <span class="category-info">
          <a href="/c/{{@topic.category.slug}}/{{@topic.category.id}}" class="category-link-wrapper">
            {{#if @topic.category.uploaded_logo.url}}
              <span class="badge-category has-logo">
                <img src={{@topic.category.uploaded_logo.url}} class="category-logo" alt="" />
              </span>
            {{else}}
              <span class="badge-category" style="background-color: #{{@topic.category.color}};">
                {{#if @topic.category.icon}}
                  {{dIcon @topic.category.icon class="category-icon"}}
                {{/if}}
              </span>
            {{/if}}
            <span class="category-slug">n/{{@topic.category.slug}}</span>
          </a>
        </span>
        <span class="separator">•</span>
      {{/if}}
      <span class="author-info">
        <UserLink @user={{@topic.creator}}>
          {{avatar @topic.creator imageSize="tiny"}}
          <span class="username">u/{{@topic.creator.username}}</span>
        </UserLink>
      </span>
      <span class="separator">•</span>
      <span class="time-info">
        {{formatDate @topic.createdAt format="tiny"}}
      </span>
    </div>
  </template>
}

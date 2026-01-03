import Component from "@glimmer/component";
import { service } from "@ember/service";
import categoryLink from "discourse/helpers/category-link";
import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import and from "truth-helpers/helpers/and";

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
          <a href="/n/{{@topic.category.slug}}" class="category-slug">n/{{@topic.category.slug}}</a>
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

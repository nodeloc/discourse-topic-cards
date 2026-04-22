import Component from "@glimmer/component";
import { trustHTML } from "@ember/template";
import TopicPostBadges from "discourse/components/topic-post-badges";
import TopicStatus from "discourse/components/topic-status";
import { apiInitializer } from "discourse/lib/api";
import { wantsNewWindow } from "discourse/lib/intercept-click";
import { i18n } from "discourse-i18n";
import TopicExcerpt from "../components/topic-excerpt";
import TopicHeader from "../components/topic-header";
import TopicLastReply from "../components/topic-last-reply";
import TopicMetadata from "../components/topic-metadata";
import TopicTags from "../components/topic-tags";
import TopicTagsMobile from "../components/topic-tags-mobile";
import TopicThumbnail from "../components/topic-thumbnail";

export default apiInitializer((api) => {
  const site = api.container.lookup("service:site");
  const router = api.container.lookup("service:router");

  function enableCards() {
    if (router.currentRouteName === "topic.fromParamsNear") {
      return settings.show_for_suggested_topics;
    }

    if (settings.show_on_categories?.length === 0) {
      return true; // no categories set, so enable cards by default
    }
    const currentCat = router.currentRoute?.attributes?.category?.id;
    if (currentCat === undefined) {
      return false; // not in a category
    }
    const categoryIds = settings.show_on_categories?.split("|").map(Number);
    return categoryIds.includes(currentCat);
  }

  api.renderInOutlet(
    "topic-list-main-link-bottom",
    class extends Component {
      static shouldRender(args, context) {
        return (
          context.siteSettings.glimmer_topic_list_mode !== "disabled" &&
          enableCards()
        );
      }

      <template>
        {{! 第一行：Header + Tags }}
        <div class="topic-card__header-row">
          <TopicHeader @topic={{@outletArgs.topic}} />
          <TopicTags @topic={{@outletArgs.topic}} />
        </div>
        
        {{! 第二行：内容区域 + 缩略图 }}
        <div class="topic-card__content-row">
          <div class="topic-card__main-content">
            <h3 class="topic-card__title">
              {{#if @outletArgs.topic.is_featured}}
                <span
                  class="featured-topic-list-icon topic-card__featured-icon"
                  title={{i18n "js.featured_topic.badge"}}
                  aria-label={{i18n "js.featured_topic.badge"}}
                >
                  <svg
                    class="featured-trophy-svg"
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="0 0 576 512"
                    width="14"
                    height="14"
                    aria-hidden="true"
                    fill="#d4a017"
                  >
                    <path d="M400 0H176c-26.5 0-48.1 21.8-47.1 48.2c.2 5.3 .4 10.6 .7 15.8H24C10.7 64 0 74.7 0 88c0 92.6 33.5 157 78.5 200.7c44.3 43.1 98.3 64.8 138.1 75.8c23.4 6.5 39.4 26 39.4 45.6c0 20.9-17 37.9-37.9 37.9H192c-17.7 0-32 14.3-32 32s14.3 32 32 32H384c17.7 0 32-14.3 32-32s-14.3-32-32-32H357.9C337 448 320 431 320 410.1c0-19.6 15.9-39.2 39.4-45.6c39.9-11 93.9-32.7 138.2-75.8C542.5 245 576 180.6 576 88c0-13.3-10.7-24-24-24H446.4c.3-5.2 .5-10.4 .7-15.8C448.1 21.8 426.5 0 400 0zM48.9 112h84.4c9.1 90.1 29.2 150.3 51.9 190.6c-24.9-11-50.8-26.5-73.2-48.3c-32-31.1-58-76-63-142.3zM464.1 254.3c-22.4 21.8-48.3 37.3-73.2 48.3c22.7-40.3 42.8-100.5 51.9-190.6h84.4c-5.1 66.3-31.1 111.2-63 142.3z" />
                  </svg>
                </span>
              {{/if}}
              <TopicStatus @topic={{@outletArgs.topic}} @disableActions={{true}} />
              <a href={{@outletArgs.topic.url}} class="topic-card__title-link">
                {{trustHTML @outletArgs.topic.fancyTitle}}
              </a>
              <TopicPostBadges
                @unreadPosts={{@outletArgs.topic.unread_posts}}
                @unseen={{@outletArgs.topic.unseen}}
                @url={{@outletArgs.topic.lastUnreadUrl}}
              />
            </h3>
            <TopicExcerpt @topic={{@outletArgs.topic}} />
          </div>
          <div class="topic-card__thumb-wrapper">
            <TopicThumbnail @topic={{@outletArgs.topic}} />
          </div>
        </div>
        
        {{! 第三行：最后回复和 Metadata }}
        <div class="topic-card__footer-row">
          <TopicLastReply @topic={{@outletArgs.topic}} />
          <TopicMetadata @topic={{@outletArgs.topic}} />
        </div>
      </template>
    }
  );

  api.registerValueTransformer(
    "topic-list-class",
    ({ value: additionalClasses }) => {
      if (enableCards()) {
        additionalClasses.push("topic-cards-list");
      }
      return additionalClasses;
    }
  );

  const classNames = ["topic-card"];

  if (settings.set_card_max_height) {
    classNames.push("has-max-height");
  }

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value: additionalClasses }) => {
      if (enableCards()) {
        return [...additionalClasses, ...classNames];
      } else {
        return additionalClasses;
      }
    }
  );

  api.registerValueTransformer("topic-list-item-mobile-layout", ({ value }) => {
    if (enableCards()) {
      return false;
    }
    return value;
  });

  api.registerValueTransformer("topic-list-columns", ({ value: columns }) => {
    if (enableCards()) {
      // 移除独立的缩略图列，改为在 outlet 中渲染
      // columns.add("thumbnail", { item: TopicThumbnail }, { before: "topic" });

      if (site.mobileView) {
        columns.add(
          "tags-mobile",
          { item: TopicTagsMobile },
          { before: "topic" }
        );
      }
    }
    return columns;
  });

  api.registerBehaviorTransformer(
    "topic-list-item-click",
    ({ context, next }) => {
      if (enableCards()) {
        const targetElement = context.event.target;
        const topic = context.topic;

        // Don't intercept clicks on user links and category links
        if (targetElement.closest(".user-link, a[data-user-card], .category-link-wrapper, .badge-category")) {
          return true;
        }

        const clickTargets = [
          "topic-list-data",
          "link-bottom-line",
          "link-top-line",
          "title",
          "topic-list-item",
          "topic-card__excerpt",
          "topic-card__excerpt-text",
          "topic-card__metadata",
          "topic-card__likes",
          "topic-card__op",
          "topic-card__last-reply",
          "topic-card__header",
          "topic-card__topic-tags",
        ];

        if (site.mobileView) {
          clickTargets.push("topic-item-metadata");
        }

        if (clickTargets.some((t) => targetElement.closest(`.${t}`))) {
          if (wantsNewWindow(context.event)) {
            return true;
          }
          context.event.preventDefault();
          return context.navigateToTopic(topic, topic.lastUnreadUrl);
        }
      }

      next();
    }
  );
});

import React, { useEffect, useRef, useState } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import { useColorMode } from '@docusaurus/theme-common';

import styles from './index.module.css';
import { JSX } from 'react/jsx-runtime';

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    // Trigger animation after component mounts
    const timer = setTimeout(() => setIsLoaded(true), 100);
    return () => clearTimeout(timer);
  }, []);

  return (
    <header className={clsx('hero', styles.heroBanner)}>
      <div className="container">
        <div className={styles.heroContent}>
          <div className={clsx(styles.logoContainer, { [styles.loaded]: isLoaded })}>
            <img 
              src="img/logo.png" 
              alt="TutorLM Logo" 
              className={styles.heroLogo}
            />
            <h1 className={styles.heroTitle}>TutorLM</h1>
          </div>
          <p className={clsx(styles.heroSubtitle, { [styles.loaded]: isLoaded })}>Your Ultimate Tutoring Companion</p>
          <p className={clsx(styles.heroDescription, { [styles.loaded]: isLoaded })}>
            Connect with amazing tutors, track your learning progress, and achieve your academic goals with ease.
          </p>
          <div className={clsx(styles.heroButtons, { [styles.loaded]: isLoaded })}>
            <Link className="button button--primary button--lg" to="/docs/manual/start">
              Get Started
            </Link>
            <a
              className={clsx('button', 'button--secondary', 'button--lg', styles.githubDownloadButton)}
              href="https://github.com/ohjime/tutorlm/releases/tag/v0.10.0-alpha"
              download
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="currentColor"
                className={styles.githubIcon}
                aria-hidden="true"
              >
                <path d="M12 0C5.37 0 0 5.373 0 12c0 5.303 3.438 9.8 8.205 11.387.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.726-4.042-1.61-4.042-1.61-.546-1.387-1.333-1.756-1.333-1.756-1.09-.745.083-.729.083-.729 1.205.085 1.84 1.237 1.84 1.237 1.07 1.834 2.807 1.304 3.492.997.108-.775.418-1.305.762-1.605-2.665-.305-5.466-1.334-5.466-5.931 0-1.31.468-2.381 1.236-3.221-.124-.303-.535-1.523.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.984-.399 3.003-.404 1.018.005 2.046.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.873.119 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.804 5.624-5.475 5.921.43.372.823 1.102.823 2.222 0 1.606-.014 2.898-.014 3.293 0 .322.216.694.825.576C20.565 21.796 24 17.299 24 12c0-6.627-5.373-12-12-12z"/>
              </svg>
              Download (GitHub)
            </a>
          </div>
        </div>
      </div>
    </header>
  );
}

// Hook for fade-in animation on scroll - optimized version
function useScrollAnimation() {
  const [isVisible, setIsVisible] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const element = ref.current;
    if (!element) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !isVisible) {
          setIsVisible(true);
          // Disconnect observer after animation triggers to improve performance
          observer.unobserve(element);
        }
      },
      { 
        threshold: 0.2,
        rootMargin: '50px 0px -50px 0px' // Trigger animation earlier
      }
    );

    observer.observe(element);

    return () => {
      observer.disconnect();
    };
  }, [isVisible]);

  return { ref, isVisible };
}

type FeatureItem = {
  title: string;
  description: string;
  color: string;
  icon: string;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Keep Track of Your Sessions',
    description: 'Monitor your learning progress with detailed session tracking. See your improvement over time and never lose track of your academic journey.',
    color: '#3B82F6',
    icon: '📊'
  },
  {
    title: 'Record Your Sessions!',
    description: 'Capture important moments from your tutoring sessions. Review key concepts and breakthroughs whenever you need them.',
    color: '#EF4444',
    icon: '🎥'
  },
  {
    title: 'Customize Your Profile',
    description: 'Make your profile uniquely yours. Showcase your learning style, subjects of interest, and academic achievements.',
    color: '#10B981',
    icon: '👤'
  },
  {
    title: 'Easy Matching with Great Tutors!',
    description: 'Find the perfect tutor for your needs with our intelligent matching system. Connect with experienced educators who understand your learning style.',
    color: '#F59E0B',
    icon: '🤝'
  },
  {
    title: 'Interactive Learning Experience',
    description: 'Engage in dynamic, interactive sessions that make learning fun and effective. Experience education like never before.',
    color: '#8B5CF6',
    icon: '🚀'
  }
];

const FeatureCard = React.memo(({ feature, index }: { feature: FeatureItem; index: number }) => {
  const { ref, isVisible } = useScrollAnimation();
  
  return (
    <div 
      ref={ref} 
      className={clsx(
        styles.featureCard, 
        styles[`featureCard${index + 1}`], 
        { [styles.fadeIn]: isVisible }
      )}
    >
      <div className={styles.featureImageContainer}>
        <div 
          className={clsx(styles.featureImage, styles[`featureImage${index + 1}`])}
        >
          <span className={styles.featureIcon}>{feature.icon}</span>
        </div>
      </div>
    </div>
  );
});

// iPhone Mock Component with rotating screenshots
const RotatingiPhone = React.memo(() => {
  const [currentScreenshot, setCurrentScreenshot] = useState(0);
  const { ref, isVisible } = useScrollAnimation();
  
  const screenshots = [
    { src: '/tutorlm/img/product-screenshots/app-home.jpg', alt: 'TutorLM Home Screen' },
    { src: '/tutorlm/img/product-screenshots/app-sessions.jpg', alt: 'Sessions Management' },
    { src: '/tutorlm/img/product-screenshots/app-chat.jpg', alt: 'Chat Interface' },
    { src: '/tutorlm/img/product-screenshots/app-profile.jpg', alt: 'Profile Customization' },
    { src: '/tutorlm/img/product-screenshots/app-settings.jpg', alt: 'Settings Screen' }
  ];

  useEffect(() => {
    if (!isVisible) return;
    
    const interval = setInterval(() => {
      setCurrentScreenshot(prev => (prev + 1) % screenshots.length);
    }, 3000);

    return () => clearInterval(interval);
  }, [isVisible, screenshots.length]);

  const handleImageError = (e: React.SyntheticEvent<HTMLImageElement>) => {
    const target = e.target as HTMLImageElement;
    const placeholder = target.nextElementSibling as HTMLElement;
    target.classList.add(styles.hidden);
    if (placeholder) placeholder.classList.remove(styles.hidden);
  };

  return (
    <div 
      ref={ref}
      className={clsx(styles.iphoneContainer, { [styles.fadeIn]: isVisible })}
    >
      <div className={styles.iphoneMockup}>
        {/* iPhone Frame */}
        <div className={styles.iphoneFrame}>
          {/* Status Bar */}
          <div className={styles.statusBar}>
            <div className={styles.statusLeft}>
              <span className={styles.time}>9:41</span>
            </div>
            <div className={styles.statusRight}>
              <div className={styles.battery}></div>
              <div className={styles.wifi}></div>
              <div className={styles.cellular}></div>
            </div>
          </div>
          
          {/* Screen Content */}
          <div className={styles.iphoneScreen}>
            {screenshots.map((screenshot, index) => (
              <div key={index} className={styles.screenshotWrapper}>
                <img
                  src={screenshot.src}
                  alt={screenshot.alt}
                  className={clsx(
                    styles.screenshot,
                    { [styles.active]: index === currentScreenshot }
                  )}
                  onError={handleImageError}
                />
                <div
                  className={clsx(
                    styles.screenshotPlaceholder,
                    styles[`placeholder${index + 1}`],
                    styles.hidden,
                    { [styles.active]: index === currentScreenshot }
                  )}
                >
                  <div className={styles.placeholderContent}>
                    <h3>{FeatureList[index]?.title || 'TutorLM'}</h3>
                    <p>{FeatureList[index]?.description.substring(0, 50) + '...' || 'Amazing features await!'}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
          
          {/* Home Indicator */}
          <div className={styles.homeIndicator}></div>
        </div>
        
        {/* Screenshot indicators */}
        <div className={styles.screenshotIndicators}>
          {screenshots.map((screenshot, index) => (
            <button
              key={index}
              className={clsx(
                styles.indicator,
                { [styles.activeIndicator]: index === currentScreenshot }
              )}
              onClick={() => setCurrentScreenshot(index)}
              aria-label={`View ${screenshot.alt}`}
              title={screenshot.alt}
            />
          ))}
        </div>
      </div>
    </div>
  );
});

FeatureCard.displayName = 'FeatureCard';
RotatingiPhone.displayName = 'RotatingiPhone';

function HomepageFeatures(): JSX.Element {
  return (
    <section className={styles.features}>
      <div className={styles.featuresContainer}>
        <div className={styles.featuresLeft}>
          <div className={styles.featuresHeader}>
            <h2 className={styles.featuresTitle}>Discover TutorLM's Powerful Features</h2>
            <p className={styles.featuresSubtitle}>
              Everything you need to succeed in your academic journey
            </p>
          </div>
          <div className={styles.featuresList}>
            {FeatureList.map((feature, idx) => (
              <div key={idx} className={styles.featureItem}>
                <div className={styles.featureNumber}>{idx + 1}</div>
                <div className={styles.featureTextContent}>
                  <h3 className={styles.featureItemTitle}>{feature.title}</h3>
                  <p className={styles.featureItemDescription}>{feature.description}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className={styles.featuresRight}>
          <RotatingiPhone />
        </div>
      </div>
    </section>
  );
}

function CallToAction(): JSX.Element {
  const { ref, isVisible } = useScrollAnimation();
  
  return (
    <section className={styles.cta} ref={ref}>
      <div className={clsx('container', styles.ctaContainer, { [styles.fadeIn]: isVisible })}>
        <h2 className={styles.ctaTitle}>Ready to Transform Your Learning?</h2>
        <p className={styles.ctaDescription}>
          Join thousands of students who are already achieving their academic goals with TutorLM.
        </p>
        <div className={styles.ctaButtons}>
          <Link className="button button--primary button--lg" to="/docs/manual/start">
            Start Learning Today
          </Link>
        </div>
      </div>
    </section>
  );
}

export default function Home(): JSX.Element {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title="TutorLM - Your Ultimate Tutoring Companion"
      description="Connect with amazing tutors, track your learning progress, and achieve your academic goals with TutorLM."
    >
      <HomepageHeader />
      <main>
        <HomepageFeatures />
        <CallToAction />
      </main>
    </Layout>
  );
}

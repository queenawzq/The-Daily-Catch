import { useState, useEffect, useRef } from "react";

const COLORS = {
  navy: "#0A1628",
  darkNavy: "#060F1D",
  blue: "#3366FF",
  periwinkle: "#7B9BFF",
  lightBlue: "#B8CCFF",
  cream: "#F2EDE4",
  warmWhite: "#FAF8F5",
  midGrey: "#8B8B97",
  lightGrey: "#C8C5BE",
  accent: "#FF6B5A",
  mint: "#4ECDC4",
  cardBg: "#111D30",
  cardBorder: "#1A2940",
};

const stories = [
  {
    id: 1,
    category: "ECONOMY",
    categoryColor: COLORS.blue,
    headline: "Fed Holds Rates Steady, Signals Summer Cut",
    hook: "The Federal Reserve kept interest rates unchanged for the fourth straight meeting.",
    context: "Inflation has cooled to 2.4% but the labor market remains tight. The Fed is waiting for more consistent data before acting. Markets are now pricing in a July cut as most likely.",
    soWhat: "If you have a variable-rate loan, student debt, or are waiting to buy a home — a summer rate cut could lower your monthly payments by fall.",
    sources: ["Reuters", "Financial Times", "AP"],
    timestamp: "7:00 AM ET",
    readTime: "30s",
  },
  {
    id: 2,
    category: "TECH",
    categoryColor: COLORS.periwinkle,
    headline: "EU Passes Landmark AI Transparency Law",
    hook: "The European Union voted to require all AI-generated content to carry visible labels.",
    context: "The law takes effect in 2027 and applies to any platform serving EU users. Companies that fail to label AI content face fines up to 6% of global revenue. The US has no equivalent legislation in progress.",
    soWhat: "Every AI tool you use — from chatbots to image generators — will need to disclose when content is machine-made. This will reshape how you interact with content online.",
    sources: ["AP", "Ars Technica", "The Economist"],
    timestamp: "7:00 AM ET",
    readTime: "30s",
  },
  {
    id: 3,
    category: "WORLD",
    categoryColor: COLORS.mint,
    headline: "India and China Reopen Key Border Crossing",
    hook: "After a four-year standoff, India and China reopened the Nathu La border pass in Sikkim.",
    context: "Relations between the two countries have been strained since a deadly 2020 clash. This reopening is largely symbolic but signals a diplomatic thaw. Trade talks are expected to follow in March.",
    soWhat: "A stable India-China relationship affects global supply chains, tech manufacturing, and the price of goods you buy. This is cautiously good news for the global economy.",
    sources: ["Reuters", "Foreign Affairs", "BBC"],
    timestamp: "7:00 AM ET",
    readTime: "30s",
  },
  {
    id: 4,
    category: "MONEY",
    categoryColor: "#E8B84B",
    headline: "Zillow Report: Rent Drops in 18 Major Cities",
    hook: "Average rents fell 2-5% in cities including Austin, Phoenix, Denver, and Atlanta.",
    context: "A surge in new apartment construction is finally hitting the market. Developers who broke ground during the pandemic are now competing for tenants. The national median rent is now $1,850, down from its $1,980 peak.",
    soWhat: "If your lease is up in the next few months, you have real negotiating power. Ask your landlord to match market rates or start looking — you may find a better deal than you expect.",
    sources: ["Zillow Research", "AP", "WSJ"],
    timestamp: "7:00 AM ET",
    readTime: "30s",
  },
  {
    id: 5,
    category: "CULTURE",
    categoryColor: COLORS.accent,
    headline: "Charli XCX's New Album Breaks Streaming Records",
    hook: "The follow-up to Brat debuted with 142 million streams in its first 24 hours on Spotify.",
    context: "It's the biggest opening day for any album in 2026. The album blends hyperpop with orchestral arrangements and features collaborations with Billie Eilish and Frank Ocean. Critics are calling it a creative leap.",
    soWhat: "If people are talking about it at work or on your timeline and you haven't listened yet — now you know why. It's everywhere, and it's apparently very good.",
    sources: ["Spotify", "Pitchfork", "The Guardian"],
    timestamp: "7:00 AM ET",
    readTime: "30s",
  },
];

// Pixel fish SVG component
const PixelFish = ({ size = 20, color = COLORS.cream }) => (
  <svg width={size} height={size * 0.7} viewBox="0 0 20 14" fill="none">
    <rect x="6" y="0" width="2" height="2" fill={color} />
    <rect x="8" y="0" width="2" height="2" fill={color} />
    <rect x="10" y="0" width="2" height="2" fill={color} />
    <rect x="4" y="2" width="2" height="2" fill={color} />
    <rect x="6" y="2" width="2" height="2" fill={color} />
    <rect x="8" y="2" width="2" height="2" fill={color} />
    <rect x="10" y="2" width="2" height="2" fill={color} />
    <rect x="12" y="2" width="2" height="2" fill={color} />
    <rect x="0" y="4" width="2" height="2" fill={color} />
    <rect x="2" y="4" width="2" height="2" fill={color} />
    <rect x="4" y="4" width="2" height="2" fill={color} />
    <rect x="6" y="4" width="2" height="2" fill={color} />
    <rect x="8" y="4" width="2" height="2" fill={color} opacity="0" />
    <rect x="10" y="4" width="2" height="2" fill={color} />
    <rect x="12" y="4" width="2" height="2" fill={color} />
    <rect x="14" y="4" width="2" height="2" fill={color} />
    <rect x="0" y="6" width="2" height="2" fill={color} />
    <rect x="2" y="6" width="2" height="2" fill={color} />
    <rect x="4" y="6" width="2" height="2" fill={color} />
    <rect x="6" y="6" width="2" height="2" fill={color} />
    <rect x="8" y="6" width="2" height="2" fill={color} />
    <rect x="10" y="6" width="2" height="2" fill={color} />
    <rect x="12" y="6" width="2" height="2" fill={color} />
    <rect x="14" y="6" width="2" height="2" fill={color} />
    <rect x="16" y="4" width="2" height="2" fill={color} />
    <rect x="16" y="6" width="2" height="2" fill={color} />
    <rect x="18" y="5" width="2" height="2" fill={color} />
    <rect x="0" y="8" width="2" height="2" fill={color} />
    <rect x="4" y="8" width="2" height="2" fill={color} />
    <rect x="6" y="8" width="2" height="2" fill={color} />
    <rect x="8" y="8" width="2" height="2" fill={color} />
    <rect x="10" y="8" width="2" height="2" fill={color} />
    <rect x="12" y="8" width="2" height="2" fill={color} />
    <rect x="6" y="10" width="2" height="2" fill={color} />
    <rect x="8" y="10" width="2" height="2" fill={color} />
    <rect x="10" y="10" width="2" height="2" fill={color} />
  </svg>
);

// Paperclip hook SVG
const PaperclipHook = ({ size = 16, color = COLORS.lightGrey }) => (
  <svg width={size} height={size * 1.8} viewBox="0 0 16 29" fill="none" stroke={color} strokeWidth="1.5">
    <path d="M4 1 L12 1 Q15 1 15 4 L15 22 Q15 27 10 27 L6 27 Q1 27 1 22 L1 8 Q1 5 4 5 L10 5 Q13 5 13 8 L13 20" strokeLinecap="round" />
  </svg>
);

const StoryCard = ({ story, index, isActive, onClick, isExpanded, onClose }) => {
  const [showSoWhat, setShowSoWhat] = useState(false);

  useEffect(() => {
    if (!isExpanded) setShowSoWhat(false);
  }, [isExpanded]);

  if (isExpanded) {
    return (
      <div
        style={{
          position: "fixed",
          top: 0, left: 0, right: 0, bottom: 0,
          background: COLORS.darkNavy,
          zIndex: 100,
          overflowY: "auto",
          animation: "fadeIn 0.3s ease",
        }}
      >
        <div style={{ maxWidth: 480, margin: "0 auto", padding: "0 24px" }}>
          {/* Header */}
          <div style={{
            display: "flex", justifyContent: "space-between", alignItems: "center",
            padding: "16px 0", position: "sticky", top: 0,
            background: COLORS.darkNavy, zIndex: 10,
            borderBottom: `1px solid ${COLORS.cardBorder}`,
          }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
              <span style={{
                fontFamily: "'IBM Plex Mono', monospace", fontSize: 10,
                color: story.categoryColor, letterSpacing: "0.12em", fontWeight: 600,
              }}>{story.category}</span>
              <span style={{
                fontFamily: "'IBM Plex Mono', monospace", fontSize: 10,
                color: COLORS.midGrey,
              }}>·  {story.readTime}</span>
            </div>
            <button
              onClick={onClose}
              style={{
                background: "none", border: `1px solid ${COLORS.cardBorder}`,
                color: COLORS.lightGrey, cursor: "pointer",
                fontFamily: "'IBM Plex Mono', monospace", fontSize: 11,
                padding: "6px 14px", borderRadius: 4,
                transition: "all 0.2s",
              }}
              onMouseEnter={e => { e.target.style.borderColor = COLORS.cream; e.target.style.color = COLORS.cream; }}
              onMouseLeave={e => { e.target.style.borderColor = COLORS.cardBorder; e.target.style.color = COLORS.lightGrey; }}
            >
              CLOSE
            </button>
          </div>

          {/* Story number */}
          <div style={{
            fontFamily: "'IBM Plex Mono', monospace", fontSize: 64, fontWeight: 700,
            color: COLORS.cardBorder, marginTop: 32, lineHeight: 1,
          }}>
            {String(index + 1).padStart(2, "0")}
          </div>

          {/* Headline */}
          <h1 style={{
            fontFamily: "'Space Grotesk', sans-serif", fontSize: 28, fontWeight: 700,
            color: COLORS.cream, lineHeight: 1.25, margin: "16px 0 24px",
            letterSpacing: "-0.02em",
          }}>
            {story.headline}
          </h1>

          {/* The Hook */}
          <div style={{ marginBottom: 32 }}>
            <div style={{
              fontFamily: "'IBM Plex Mono', monospace", fontSize: 9,
              color: COLORS.midGrey, letterSpacing: "0.15em", marginBottom: 10,
            }}>WHAT HAPPENED</div>
            <p style={{
              fontFamily: "'Space Grotesk', sans-serif", fontSize: 17,
              color: COLORS.cream, lineHeight: 1.6, margin: 0,
              borderLeft: `2px solid ${story.categoryColor}`,
              paddingLeft: 16,
            }}>
              {story.hook}
            </p>
          </div>

          {/* The Context */}
          <div style={{ marginBottom: 32 }}>
            <div style={{
              fontFamily: "'IBM Plex Mono', monospace", fontSize: 9,
              color: COLORS.midGrey, letterSpacing: "0.15em", marginBottom: 10,
            }}>WHY IT MATTERS NOW</div>
            <p style={{
              fontFamily: "'Space Grotesk', sans-serif", fontSize: 15,
              color: COLORS.lightGrey, lineHeight: 1.7, margin: 0,
            }}>
              {story.context}
            </p>
          </div>

          {/* The So What — expandable */}
          <div style={{
            marginBottom: 32,
            background: showSoWhat ? COLORS.cardBg : "transparent",
            border: `1px solid ${showSoWhat ? story.categoryColor + "40" : COLORS.cardBorder}`,
            borderRadius: 8, padding: 20,
            cursor: showSoWhat ? "default" : "pointer",
            transition: "all 0.3s ease",
          }}
            onClick={() => !showSoWhat && setShowSoWhat(true)}
          >
            <div style={{
              display: "flex", justifyContent: "space-between", alignItems: "center",
            }}>
              <div style={{
                fontFamily: "'IBM Plex Mono', monospace", fontSize: 9,
                color: story.categoryColor, letterSpacing: "0.15em",
              }}>
                {showSoWhat ? "HOW THIS AFFECTS YOU" : "TAP TO SEE HOW THIS AFFECTS YOU →"}
              </div>
            </div>
            {showSoWhat && (
              <p style={{
                fontFamily: "'Space Grotesk', sans-serif", fontSize: 15,
                color: COLORS.cream, lineHeight: 1.7, margin: "14px 0 0",
                animation: "fadeIn 0.4s ease",
              }}>
                {story.soWhat}
              </p>
            )}
          </div>

          {/* Sources */}
          <div style={{
            display: "flex", alignItems: "center", gap: 6,
            paddingBottom: 40,
          }}>
            <PaperclipHook size={10} color={COLORS.midGrey} />
            <span style={{
              fontFamily: "'IBM Plex Mono', monospace", fontSize: 10,
              color: COLORS.midGrey,
            }}>
              {story.sources.join(" · ")} — as of {story.timestamp}
            </span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div
      onClick={onClick}
      style={{
        background: COLORS.cardBg,
        border: `1px solid ${isActive ? story.categoryColor + "60" : COLORS.cardBorder}`,
        borderRadius: 10,
        padding: "20px 20px 18px",
        cursor: "pointer",
        transition: "all 0.25s ease",
        transform: isActive ? "scale(1.01)" : "scale(1)",
        animation: `slideUp 0.4s ease ${index * 0.08}s both`,
      }}
      onMouseEnter={e => {
        e.currentTarget.style.borderColor = story.categoryColor + "60";
        e.currentTarget.style.transform = "scale(1.01)";
      }}
      onMouseLeave={e => {
        if (!isActive) {
          e.currentTarget.style.borderColor = COLORS.cardBorder;
          e.currentTarget.style.transform = "scale(1)";
        }
      }}
    >
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <span style={{
            fontFamily: "'IBM Plex Mono', monospace", fontSize: 10,
            color: story.categoryColor, letterSpacing: "0.12em", fontWeight: 600,
          }}>{story.category}</span>
          <span style={{
            fontFamily: "'IBM Plex Mono', monospace", fontSize: 10,
            color: COLORS.midGrey,
          }}>· {story.readTime}</span>
        </div>
        <span style={{
          fontFamily: "'IBM Plex Mono', monospace", fontSize: 24,
          color: COLORS.cardBorder, fontWeight: 700, lineHeight: 1,
        }}>{String(index + 1).padStart(2, "0")}</span>
      </div>

      <h3 style={{
        fontFamily: "'Space Grotesk', sans-serif", fontSize: 18,
        color: COLORS.cream, fontWeight: 600, lineHeight: 1.3,
        margin: "0 0 8px", letterSpacing: "-0.01em",
      }}>{story.headline}</h3>

      <p style={{
        fontFamily: "'Space Grotesk', sans-serif", fontSize: 13,
        color: COLORS.midGrey, lineHeight: 1.5, margin: 0,
      }}>{story.hook}</p>
    </div>
  );
};

const ProgressDots = ({ total, current }) => (
  <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
    {Array.from({ length: total }).map((_, i) => (
      <div
        key={i}
        style={{
          width: i <= current ? 20 : 6,
          height: 6,
          borderRadius: 3,
          background: i <= current ? COLORS.blue : COLORS.cardBorder,
          transition: "all 0.4s ease",
        }}
      />
    ))}
  </div>
);

export default function DailyCatchApp() {
  const [expandedStory, setExpandedStory] = useState(null);
  const [storiesRead, setStoriesRead] = useState(new Set());
  const [showComplete, setShowComplete] = useState(false);

  const handleStoryClick = (index) => {
    setExpandedStory(index);
    setStoriesRead(prev => new Set([...prev, index]));
  };

  const handleClose = () => {
    setExpandedStory(null);
    if (storiesRead.size >= 5) {
      setTimeout(() => setShowComplete(true), 400);
    }
  };

  return (
    <div style={{
      minHeight: "100vh",
      background: COLORS.darkNavy,
      fontFamily: "'Space Grotesk', sans-serif",
    }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap');
        
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        
        @keyframes slideUp {
          from { opacity: 0; transform: translateY(16px); }
          to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 0.4; }
          50% { opacity: 1; }
        }
        
        * { box-sizing: border-box; -webkit-font-smoothing: antialiased; }
        
        ::-webkit-scrollbar { width: 0; }
      `}</style>

      <div style={{ maxWidth: 480, margin: "0 auto", padding: "0 20px" }}>

        {/* Top Bar */}
        <div style={{
          display: "flex", justifyContent: "space-between", alignItems: "center",
          padding: "20px 0 8px",
          borderBottom: `1px solid ${COLORS.cardBorder}`,
        }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <PixelFish size={22} color={COLORS.cream} />
            <span style={{
              fontFamily: "'IBM Plex Mono', monospace",
              fontSize: 13, fontWeight: 700, color: COLORS.cream,
              letterSpacing: "0.06em",
            }}>THE DAILY CATCH</span>
          </div>
          <div style={{
            fontFamily: "'IBM Plex Mono', monospace",
            fontSize: 10, color: COLORS.midGrey,
          }}>FEB 25, 2026</div>
        </div>

        {/* Greeting */}
        <div style={{ padding: "28px 0 8px" }}>
          <h1 style={{
            fontFamily: "'Space Grotesk', sans-serif",
            fontSize: 26, fontWeight: 700, color: COLORS.cream,
            margin: "0 0 6px", letterSpacing: "-0.02em",
          }}>
            Today's Catch
          </h1>
          <p style={{
            fontFamily: "'IBM Plex Mono', monospace",
            fontSize: 12, color: COLORS.midGrey, margin: 0,
            lineHeight: 1.5,
          }}>
            5 stories · ~2 min · as of 7:00 AM ET
          </p>
        </div>

        {/* Progress */}
        <div style={{
          display: "flex", justifyContent: "space-between", alignItems: "center",
          padding: "16px 0 20px",
        }}>
          <ProgressDots total={5} current={storiesRead.size - 1} />
          <span style={{
            fontFamily: "'IBM Plex Mono', monospace",
            fontSize: 10, color: storiesRead.size === 5 ? COLORS.mint : COLORS.midGrey,
            transition: "color 0.3s",
          }}>
            {storiesRead.size === 5 ? "ALL CAUGHT UP ✓" : `${storiesRead.size}/5 READ`}
          </span>
        </div>

        {/* Story Cards */}
        <div style={{ display: "flex", flexDirection: "column", gap: 10, paddingBottom: 40 }}>
          {stories.map((story, i) => (
            <StoryCard
              key={story.id}
              story={story}
              index={i}
              isActive={storiesRead.has(i)}
              onClick={() => handleStoryClick(i)}
              isExpanded={expandedStory === i}
              onClose={handleClose}
            />
          ))}
        </div>

        {/* Completion State */}
        {showComplete && expandedStory === null && (
          <div style={{
            textAlign: "center", padding: "20px 0 60px",
            animation: "fadeIn 0.6s ease",
          }}>
            <div style={{
              width: 1, height: 40, background: COLORS.cardBorder,
              margin: "0 auto 24px",
            }} />
            <PixelFish size={32} color={COLORS.mint} />
            <p style={{
              fontFamily: "'Space Grotesk', sans-serif",
              fontSize: 20, fontWeight: 600, color: COLORS.cream,
              margin: "16px 0 6px",
            }}>
              Consider yourself caught up.
            </p>
            <p style={{
              fontFamily: "'IBM Plex Mono', monospace",
              fontSize: 12, color: COLORS.midGrey, margin: 0,
              lineHeight: 1.6,
            }}>
              That's your world in 5 stories.<br />
              Go live your life. See you tomorrow.
            </p>
            <div style={{
              marginTop: 24,
              padding: "12px 24px",
              background: COLORS.cardBg,
              border: `1px solid ${COLORS.cardBorder}`,
              borderRadius: 8,
              display: "inline-block",
            }}>
              <span style={{
                fontFamily: "'IBM Plex Mono', monospace",
                fontSize: 10, color: COLORS.midGrey,
                letterSpacing: "0.1em",
              }}>NEXT CATCH TOMORROW · 7:00 AM ET</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
